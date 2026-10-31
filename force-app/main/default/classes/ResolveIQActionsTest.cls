@IsTest private class ResolveIQActionsTest {
 @IsTest static void actions() {
  Contact c=new Contact(LastName='Action',Email='action@example.com');insert c;
  ResolveIQLookupAction.Request lookup=new ResolveIQLookupAction.Request();lookup.email=c.Email;
  System.assert(ResolveIQLookupAction.execute(new List<ResolveIQLookupAction.Request>{lookup})[0].result.contains(c.Id));
  ResolveIQCreateAction.Request req=new ResolveIQCreateAction.Request();req.contactId=c.Id;req.subject='Agent test';req.description='Description';req.category='Hardware';
  Test.startTest();String result=ResolveIQCreateAction.execute(new List<ResolveIQCreateAction.Request>{req})[0].result;Test.stopTest();
  System.assert(result.contains('CaseNumber'));System.assertEquals(1,[SELECT count() FROM Case WHERE ContactId=:c.Id]);
  String read=ResolveIQLookupAction.execute(new List<ResolveIQLookupAction.Request>{lookup})[0].result;System.assert(read.contains('Agent test'));
  req.category='Invalid';System.assert(ResolveIQCreateAction.execute(new List<ResolveIQCreateAction.Request>{req})[0].result.contains('echouee'));
 }
}