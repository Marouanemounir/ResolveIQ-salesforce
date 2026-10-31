public with sharing class ResolveIQController {
 @AuraEnabled(cacheable=true) public static List<Contact> findContacts(String email) {
  if(String.isBlank(email)) throw new AuraHandledException('Renseignez un email.');
  String normalized=email.trim();
  return [SELECT Id,Name,Email,AccountId FROM Contact WHERE Email=:normalized WITH USER_MODE LIMIT 20];
 }
 @AuraEnabled public static List<Case> getCases(Id contactId) {
  return [SELECT Id,CaseNumber,Subject,Status,Category__c,IsClosed,Resolution_Summary__c FROM Case WHERE ContactId=:contactId WITH USER_MODE ORDER BY CreatedDate DESC LIMIT 100];
 }
 @AuraEnabled public static Id createCase(Id contactId,String subject,String description,String category) {
  if(contactId==null || String.isBlank(subject) || String.isBlank(description)) throw new AuraHandledException('Contact, objet et description obligatoires.');
  if(!new Set<String>{'Hardware','Software','Billing','Other'}.contains(category)) throw new AuraHandledException('Catégorie invalide.');
  if(subject.length()>255 || description.length()>32000) throw new AuraHandledException('Texte trop long.');
  List<Contact> clients=[SELECT Id,AccountId FROM Contact WHERE Id=:contactId WITH USER_MODE];
  if(clients.isEmpty()) throw new AuraHandledException('Client inaccessible.');
  Case ticket=new Case(ContactId=contactId,AccountId=clients[0].AccountId,Subject=subject.trim(),Description=description.trim(),Category__c=category,Status='New',Origin='Web',Priority='Medium');
  insert as user ticket;
  return ticket.Id;
 }
 @AuraEnabled public static void closeCase(Id caseId,String resolution) {
  if(String.isBlank(resolution) || resolution.length()>255) throw new AuraHandledException('Une résolution de 1 à 255 caractères est obligatoire.');
  List<Case> tickets=[SELECT Id,IsClosed FROM Case WHERE Id=:caseId WITH USER_MODE];
  if(tickets.isEmpty()) throw new AuraHandledException('Ticket inaccessible.');
  if(tickets[0].IsClosed) throw new AuraHandledException('Ticket déjà fermé.');
  Case ticket=new Case(Id=caseId,Status='Closed',Resolution_Summary__c=resolution.trim());
  update as user ticket;
 }
}