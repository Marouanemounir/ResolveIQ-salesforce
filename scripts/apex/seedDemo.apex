// Reutilisable dans chaque Developer Org. Ne modifie pas les donnees existantes.
Savepoint sp = Database.setSavepoint();
try {
    List<Account> accounts = [SELECT Id FROM Account WHERE Name='ResolveIQ Demo'];
    System.assert(accounts.size()<=1, 'Plusieurs comptes ResolveIQ Demo existent : verifier avant import.');
    Account account;
    if (accounts.isEmpty()) { account=new Account(Name='ResolveIQ Demo'); insert account; }
    else { account=accounts[0]; }
    List<String> firstNames=new List<String>{'Sara','Yassine','Emma'};
    List<String> emails=new List<String>{'sara@example.com','yassine@example.com','emma@example.com'};
    Map<String,Contact> contacts=new Map<String,Contact>();
    for(Integer i=0;i<emails.size();i++) {
        String email=emails[i];
        List<Contact> existing=[SELECT Id,AccountId FROM Contact WHERE Email=:email AND LastName='Demo'];
        System.assert(existing.size()<=1,'Plusieurs contacts correspondent a '+email);
        Contact c;
        if(existing.isEmpty()) {
            c=new Contact(FirstName=firstNames[i],LastName='Demo',Email=email,AccountId=account.Id,Preferred_Language__c=i==2?'en':'fr');
            insert c;
        } else {
            c=existing[0];
            System.assertEquals(account.Id,c.AccountId,'Contact deja lie a un autre compte : '+email);
        }
        contacts.put(email,c);
    }
    List<String> subjects=new List<String>{'Ordinateur qui ne démarre plus','Application bloquée à la connexion','Facture reçue deux fois','Problème résolu après mise à jour'};
    List<String> descriptions=new List<String>{'Le client indique que son ordinateur ne démarre plus, même branché au secteur. Vérifier l’alimentation et le matériel.','Sara ne peut plus se connecter à son application : un message d’erreur apparaît après la saisie de ses identifiants.','Yassine a reçu deux exemplaires de la même facture et souhaite vérifier qu’aucun double paiement n’est demandé.','Emma signalait un dysfonctionnement de son application. Une mise à jour a été installée et le fonctionnement a été confirmé.'};
    List<String> categories=new List<String>{'Hardware','Software','Billing','Software'};
    List<String> statuses=new List<String>{'New','Working','New','Closed'};
    List<String> owners=new List<String>{emails[0],emails[0],emails[1],emails[2]};
    for(Integer i=0;i<subjects.size();i++) {
        String subject=subjects[i];
        List<Case> existing=[SELECT Id,ContactId FROM Case WHERE AccountId=:account.Id AND Subject=:subject];
        System.assert(existing.size()<=1,'Plusieurs tickets correspondent a '+subject);
        if(existing.isEmpty()) {
            Case ticket=new Case(AccountId=account.Id,ContactId=contacts.get(owners[i]).Id,Subject=subject,Description=descriptions[i],Category__c=categories[i],Status=statuses[i],Origin='Web',Priority='Medium');
            if(i==3) ticket.Resolution_Summary__c='Mise à jour installée ; fonctionnement confirmé par le client.';
            insert ticket;
        } else {
            System.assertEquals(contacts.get(owners[i]).Id,existing[0].ContactId,'Contact incoherent pour '+subject);
        }
    }
    System.debug('RESOLVEIQ_DEMO_READY AccountId='+account.Id);
} catch(Exception e) {
    Database.rollback(sp);
    throw e;
}
