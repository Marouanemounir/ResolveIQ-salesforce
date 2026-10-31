import { LightningElement } from 'lwc';
import findContacts from '@salesforce/apex/ResolveIQController.findContacts';
import getCases from '@salesforce/apex/ResolveIQController.getCases';
import createCase from '@salesforce/apex/ResolveIQController.createCase';
import closeCase from '@salesforce/apex/ResolveIQController.closeCase';
export default class ResolveIQConsole extends LightningElement {
 email=''; contacts=[]; contactId=''; cases=[]; subject=''; description=''; category='Other'; resolution=''; caseId=''; busy=false; message=''; error='';
 categories=['Hardware','Software','Billing','Other'].map(v=>({label:v,value:v}));
 columns=[{label:'Numéro',fieldName:'CaseNumber'},{label:'Objet',fieldName:'Subject'},{label:'Statut',fieldName:'Status'},{label:'Catégorie',fieldName:'Category__c'},{type:'button',typeAttributes:{label:'Sélectionner',name:'select'}}];
 get options(){return this.contacts.map(c=>({label:c.Name+' — '+c.Email,value:c.Id}));}
 get hasContact(){return Boolean(this.contactId);}
 get hasCase(){return Boolean(this.caseId);}
 change(e){this[e.target.name]=e.detail.value ?? e.target.value;}
 async run(action){this.busy=true;this.error='';this.message='';try{await action();}catch(e){this.error=e.body?.message || e.message || 'Une erreur est survenue.';}finally{this.busy=false;}}
 async search(){await this.run(async()=>{this.contacts=[];this.contactId='';this.cases=[];this.caseId='';this.contacts=await findContacts({email:this.email});if(this.contacts.length===1){this.contactId=this.contacts[0].Id;await this.refresh();}else if(!this.contacts.length){this.message='Aucun client trouvé.';}});}
 async selectContact(e){this.contactId=e.detail.value;this.caseId='';await this.run(()=>this.refresh());}
 async refresh(){this.cases=await getCases({contactId:this.contactId});}
 async create(){await this.run(async()=>{await createCase({contactId:this.contactId,subject:this.subject,description:this.description,category:this.category});this.subject='';this.description='';await this.refresh();this.message='Ticket créé.';});}
 selectCase(e){this.caseId=e.detail.row.Id;this.resolution=e.detail.row.Resolution_Summary__c || '';this.message='Ticket '+e.detail.row.CaseNumber+' sélectionné.';}
 async close(){await this.run(async()=>{await closeCase({caseId:this.caseId,resolution:this.resolution});await this.refresh();this.caseId='';this.resolution='';this.message='Ticket fermé.';});}
}