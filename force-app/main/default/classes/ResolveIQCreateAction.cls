public with sharing class ResolveIQCreateAction {
 public class Request {
  @InvocableVariable(required=true) public Id contactId;
  @InvocableVariable(required=true) public String subject;
  @InvocableVariable(required=true) public String description;
  @InvocableVariable(required=true) public String category;
 }
 public class Result { @InvocableVariable public String result; }
 @InvocableMethod(label='ResolveIQ Creer ticket confirme' description='Creer un ticket pour un contact CRM selectionne, uniquement apres confirmation explicite du conseiller.')
 public static List<Result> execute(List<Request> requests) {
  List<Result> results=new List<Result>();
  if(requests.size()>10) {for(Request r:requests){Result o=new Result();o.result='Erreur: maximum 10 demandes par appel.';results.add(o);}return results;}
  for(Request r:requests){Result o=new Result();try{Id id=ResolveIQController.createCase(r.contactId,r.subject,r.description,r.category);Case c=[SELECT Id,CaseNumber,Subject,Status FROM Case WHERE Id=:id WITH USER_MODE];o.result=JSON.serialize(c);}catch(Exception e){o.result='Creation echouee. Verifier les champs requis et les permissions; aucun numero de ticket ne doit etre annonce.';}results.add(o);}return results;
 }
}