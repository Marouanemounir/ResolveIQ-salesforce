public with sharing class ResolveIQLookupAction {
 public class Request { @InvocableVariable(required=true label='Email du client') public String email; }
 public class Result { @InvocableVariable(label='Resultat CRM JSON') public String result; }
 @InvocableMethod(label='ResolveIQ Rechercher client et tickets' description='Recherche interne exacte par email. Un email ne constitue pas une verification d identite pour un portail public.')
 public static List<Result> execute(List<Request> requests) {
  Set<String> emails=new Set<String>();for(Request r:requests) if(!String.isBlank(r.email)) emails.add(r.email.trim());
  Map<String,List<Contact>> found=new Map<String,List<Contact>>();Set<Id> ids=new Set<Id>();
  for(Contact c:[SELECT Id,Name,Email,AccountId FROM Contact WHERE Email IN :emails WITH USER_MODE LIMIT 200]) {
   String key=c.Email.toLowerCase();if(!found.containsKey(key))found.put(key,new List<Contact>());found.get(key).add(c);ids.add(c.Id);
  }
  Map<Id,List<Case>> tickets=new Map<Id,List<Case>>();
  for(Case c:[SELECT Id,CaseNumber,Subject,Status,Category__c,ContactId FROM Case WHERE ContactId IN :ids WITH USER_MODE ORDER BY CreatedDate DESC LIMIT 200]) {
   if(!tickets.containsKey(c.ContactId)) tickets.put(c.ContactId,new List<Case>());tickets.get(c.ContactId).add(c);
  }
  List<Result> results=new List<Result>();for(Request r:requests){Result o=new Result();String key=String.isBlank(r.email)?'':r.email.trim().toLowerCase();List<Contact> matches=found.containsKey(key)?found.get(key):new List<Contact>();Map<String,Object> data=new Map<String,Object>{'contacts'=>matches,'ticketsByContact'=>tickets,'instruction'=>'Utiliser uniquement les identifiants CRM retournes. En cas de plusieurs contacts, demander lequel choisir.'};
   Map<Id,List<Case>> related=new Map<Id,List<Case>>();for(Contact c:matches)if(tickets.containsKey(c.Id))related.put(c.Id,tickets.get(c.Id));data.put('ticketsByContact',related);o.result=JSON.serialize(data);results.add(o);}return results;
 }
}