@IsTest private class ResolveIQControllerTest {
 @IsTest static void lifecycle() {
  Account a=new Account(Name='Test');insert a;
  Contact c=new Contact(LastName='Test',Email='test@example.com',AccountId=a.Id);insert c;
  Test.startTest();
  System.assertEquals(1,ResolveIQController.findContacts(' test@example.com ').size());
  Id ticket=ResolveIQController.createCase(c.Id,'Test ticket','Description','Hardware');
  System.assertEquals(1,ResolveIQController.getCases(c.Id).size());
  ResolveIQController.closeCase(ticket,'Résolu');
  System.assertEquals(true,[SELECT IsClosed FROM Case WHERE Id=:ticket].IsClosed);
  try {ResolveIQController.closeCase(ticket,'Encore');System.assert(false);}catch(AuraHandledException expected){}
  Test.stopTest();
 }
 @IsTest static void invalidInputs() {
  try {ResolveIQController.findContacts('');System.assert(false);}catch(AuraHandledException expected){}
  try {ResolveIQController.createCase(null,'','','Other');System.assert(false);}catch(AuraHandledException expected){}
  try {ResolveIQController.createCase(UserInfo.getUserId(),'a','b','Invalid');System.assert(false);}catch(AuraHandledException expected){}
  try {ResolveIQController.closeCase(null,'');System.assert(false);}catch(AuraHandledException expected){}
 }
}