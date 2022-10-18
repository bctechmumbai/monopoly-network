from django.db import models
from datetime import datetime
import json
from pathlib import Path
import hashlib
from .validators import validate_file_extension
import base64
from django.conf import settings

# Create your models here.
#state_id= models.IntegerField(blank=True, null=True)
    
# master models

class State(models.Model):
    state_code = models.CharField(primary_key=True, max_length=4,blank=False, null=False )
    state_name = models.CharField(max_length=255, blank=False, null=False)
    state_namell = models.CharField(max_length=255, blank=False, null=True)
    census_code_2001 = models.CharField(max_length=255, blank=False, null=True)
    census_code_2011 = models.CharField(max_length=255, blank=False, null=True)
    country = models.CharField(max_length=4, default='91', blank=False, null=True)
    created = models.DateTimeField(default=datetime.now, blank=False)
    modified = models.DateTimeField(default=datetime.now,  blank=False)
    statetype =  models.CharField(max_length=2)

    def __str__(self):
        # return '(' + str(self.designationcode) + ') - ' + str(self.designationname)
        return self.state_name

    class Meta:
        managed = True
        db_table = 'states'
        

class District(models.Model):
    district_id= models.IntegerField(blank=True, null=True)
    district_code = models.CharField(primary_key=True, max_length=4, blank=False, null=False )
    district_name = models.CharField(max_length=255, blank=True, null=True)
    district_namell = models.CharField(max_length=255, blank=True, null=True)
    state = models.ForeignKey(State, on_delete=models.CASCADE, blank=False, null=False)
    census_code_2011 = models.CharField(max_length=4, blank=True, null=True)
    census_code_2001 = models.CharField(max_length=4, blank=True, null=True)
    created = models.DateTimeField(default=datetime.now, blank=False)
    modified = models.DateTimeField(default=datetime.now, blank=False)
    

    def __str__(self):
        # return '(' + str(self.district_code) + ')' + str(self.district_name)
         return self.district_name
    class Meta:
        managed = True
        db_table = 'districts'

class Designation(models.Model):
    
    designation_code = models.CharField(primary_key=True, max_length=4, unique=True)
    designation_name = models.CharField(max_length=255, blank=False, null=False)
    designation_namell = models.CharField(max_length=255, blank=False, null=True)
    created = models.DateTimeField(default=datetime.now, blank=False)
    modified = models.DateTimeField(default=datetime.now,  blank=False)
    def __str__(self):
        # return '(' + str(self.designationcode) + ') - ' + str(self.designationname)
         return self.designation_name

    class Meta:
        managed = True
        db_table = 'designation'


class Post(models.Model):
   
    post_code = models.CharField(primary_key=True, max_length=4, unique=True)
    post_name = models.CharField(max_length=255, blank=False, null=False)
    post_namell = models.CharField(max_length=255, blank=False, null=True)
    created = models.DateTimeField(default=datetime.now,  blank=False)
    modified = models.DateTimeField(default=datetime.now,  blank=False)
    
 

    def __str__(self):
        #return '(' + str(self.postcode) + ') - ' + str(self.postname)
        return self.post_name

    class Meta:
        managed = True
        db_table = 'post'




class Employee(models.Model):

    employee_code =models.IntegerField(primary_key=True, unique=True)
    name = models.CharField(max_length=100)
    birth_date = models.DateField(blank=False, null=False)
    joining_date = models.DateField(blank=False, null=False)
    designation =  models.ForeignKey(Designation, on_delete=models.CASCADE  )
    post =  models.ForeignKey(Post, on_delete=models.CASCADE)
    place_of_Posting =  models.CharField(max_length=100, blank=False, null=True)
    created = models.DateTimeField(default=datetime.now,  blank=False)
    modified = models.DateTimeField(default=datetime.now,  blank=False)

    # def get_absolute_url(self):
    #     return reverse('employee-detail', kwargs={'pk': self.pk})
    
    def __str__(self):
        return  '(' + str(self.employee_code) + ') - ' + str(self.name) 

    class Meta:
        db_table = "employee"
        ordering = ['employee_code']#sorts the records ascending using 'eid' field


class TransferLocationType(models.Model):
    transferlocationtype_code=models.CharField(primary_key=True, max_length=4, unique=True)
    transferlocationtype_name=models.CharField(max_length=255, blank=False, null=False)
    created = models.DateTimeField(default=datetime.now,  blank=False)
    modified = models.DateTimeField(default=datetime.now,  blank=False)
    def __str__(self):
            return str(self.transferlocationtype_name)
        
    class Meta:
        managed = True
        db_table = 'transferlocationtype'
        ordering =['transferlocationtype_name']

class ModeOfTransfer(models.Model):
    transfermode_code=models.CharField(primary_key=True, max_length=4, unique=True)
    transfermode_name=models.CharField(max_length=255, blank=False, null=False)
    created = models.DateTimeField(default=datetime.now,  blank=False)
    modified = models.DateTimeField(default=datetime.now,  blank=False)
    
    def __str__(self):
        return str(self.transfermode_name)
        
    class Meta:
        managed = True
        db_table = 'modeoftransfer'
         

    
    
class Transfer(models.Model):
    transfer_id = models.AutoField(primary_key=True,serialize = False,verbose_name ='ID')   
    employee = models.ForeignKey(Employee, on_delete=models.DO_NOTHING)
    from_type = models.ForeignKey(TransferLocationType, on_delete=models.DO_NOTHING, related_name='from_type') 
    from_location_state=models.ForeignKey(State, on_delete=models.DO_NOTHING, related_name='from_location_state')
    from_location_district=models.ForeignKey(District, on_delete=models.DO_NOTHING, related_name='from_location_district')
    to_type = models.ForeignKey(TransferLocationType, on_delete=models.DO_NOTHING, related_name='to_type')
    to_location_state=models.ForeignKey(State, on_delete=models.DO_NOTHING, related_name='to_location_state')
    to_location_district=models.ForeignKey(District, on_delete=models.DO_NOTHING, related_name='to_location_district')
    transfer_order_no=models.CharField(max_length=255, blank=False, null=False)
    transfer_order_date=models.DateField(blank=False, null=False)
    transfer_order_copy=models.FileField(upload_to='uploads/transfer_orders/', validators=[validate_file_extension])
    transfer_order_copy_bckey=models.CharField(max_length=255,blank=True,null=True)
    transfer_order_copy_bc_tranid=models.CharField(max_length=255,blank=True,null=True)
    relieveing_order_no=models.CharField(max_length=255, blank=False, null=False)
    relieveing_order_date=models.DateField(blank=False, null=False)
    relieveing_order_copy=models.FileField(upload_to='uploads/relieveing_orders/', validators=[validate_file_extension], blank=True, null=True)
    relieveing_order_copy_bckey=models.CharField(max_length=255,blank=True,null=True)
    relieveing_order_copy_bc_tranid=models.CharField(max_length=255,blank=True,null=True)
    joining_order_no=models.CharField(max_length=255, blank=False, null=False)
    joining_order_date=models.DateField(blank=False, null=False)
    joining_order_copy=models.FileField(upload_to='uploads/joining_orders/', validators=[validate_file_extension], blank=True, null=True)
    joining_order_copy_bckey=models.CharField(max_length=255,blank=True,null=True)
    joining_order_copy_bc_tranid=models.CharField(max_length=255,blank=True,null=True)
    #mode_of_transfer=models.CharField(max_length=255, blank=False, null=False)
    mode_of_transfer=models.ForeignKey(ModeOfTransfer, on_delete=models.DO_NOTHING, related_name='mode_of_transfer')
    post_of_joining= models.ForeignKey(Post, on_delete=models.DO_NOTHING)
    created = models.DateTimeField(default=datetime.now,  blank=False)
    modified = models.DateTimeField(default=datetime.now,  blank=False)

    
    
    def __str__(self):
        return str(self.employee) + ' -(' + str(self.transfer_order_no) + ') - from' + str(self.from_location_district)+' to '+str(self.to_location_district)
        
    def save(self, *args, **kwargs):
        orderkey=str(self.employee.employee_code) + str(self.transfer_order_no)
        order_content_bytes=self.transfer_order_copy.read()
        # arr = bytes(order_content_bytes, 'utf-8')
        # print(arr)
        
        blob = base64.b64encode(order_content_bytes)
        
         
        # pdfcontent  =   base64.b64decode(blob)
        # with open('downloads/temp123.pdf', 'wb') as f:
        #     f.write(pdfcontent)
        
        orderhash = hashlib.sha256(order_content_bytes).hexdigest()

        transferdata={
            "nicOrdersId": str(orderkey), 
            "empCode":str(self.employee.employee_code),
            "orderType":"Transfer",
            "orderNo":str(self.transfer_order_no),
            "OrderDate":str(self.transfer_order_date),
            "OrderCopyName":str(self.transfer_order_copy),
            "OrderCopybytes":blob.decode('utf-8'),
            "orderCopyHash": orderhash
            }
        jsondata= json.dumps(transferdata)
        file = open('transferdata.json', 'w')
        file.write(jsondata)
        file.close()
        # print(jsondata)
        # base64data = transferdata["orderCopyHash"]
        # pdfcontentnew = base64.b64decode(base64data)
        # with open('downloads/temp1234.pdf', 'wb') as f:
        #     f.write(base64.b64decode(transferdata["orderCopyHash"]))    
           
        import requests
        headers = {'content-type': 'application/json'}
        api_url= settings.BLOCKCHAIN_API_URL
        api_method="createNicOrder/"
        # api_call_str = "http://10.152.2.56:8080/api/createNicOrder/"
        api_call_str = api_url + api_method
        response = requests.post(api_call_str, data = jsondata, headers=headers )
        print(response) 
        
        self.transfer_order_copy_bckey=orderkey
        self.transfer_order_copy_bc_tranid=response.status_code
       
        super(Transfer, self).save(*args, **kwargs)
    
    class Meta:
        managed = True
        db_table = 'transfer'
        ordering = ['employee','transfer_order_date']
        
                
class Promotion(models.Model):
    promotion_id = models.AutoField(primary_key=True,serialize = False,verbose_name ='ID')   
    employee = models.ForeignKey(Employee, on_delete=models.DO_NOTHING) 
    from_designation=models.ForeignKey(Designation, on_delete=models.DO_NOTHING, related_name='from_designation') 
    to_designation=models.ForeignKey(Designation, on_delete=models.DO_NOTHING, related_name='to_designation') 
    order_no=models.CharField(max_length=255, blank=False, null=False)
    order_date=models.DateField(blank=False, null=False)
    promotion_date=models.DateField(blank=False, null=False)
    place_of_joining= models.CharField(max_length=255, blank=False, null=False)
    created = models.DateTimeField(default=datetime.now,  blank=False)
    modified = models.DateTimeField(default=datetime.now,  blank=False)
    

    def __str__(self):
        return str(self.employee) + ' -(' + str(self.order_no) + ') - from' + str(self.from_designation)+' to '+str(self.to_designation)
        
    class Meta:
        managed = True
        db_table = 'promotion'
        ordering = ['employee','order_date']

class BeDepot(models.Model):
    depot_code = models.CharField(max_length=20)
    depot_name = models.CharField(max_length=200)
    scheme_code = models.CharField(max_length=20)
    scheme_name = models.CharField(max_length=200)
    commodity_code = models.CharField(max_length=20)
    commodity_name = models.CharField(max_length=200)
    quantity = models.FloatField()
 
    def __str__(self):
        return str(self.depot_name)
        
    class Meta:
        managed = True

class SeedCertificate(models.Model):
    # assetId = models.CharField(max_length=50, verbose_name=u"Tag Number" )    
    # crop = models.CharField(max_length=50, verbose_name=u"Crop Name")
    # variety = models.CharField(max_length=50, verbose_name=u"Crop Variety")
    # certclass = models.CharField(max_length=20, verbose_name=u"Certificate Class")
    # quantity = models.CharField(max_length=20, verbose_name=u"Quantity")
    # LotNumber = models.CharField(max_length=20, verbose_name=u"Lot Number")
    # dateOfIssue = models.DateField(blank=True, null=True, verbose_name=u"Date of Issue")
    # growerName = models.CharField(max_length=50, verbose_name=u"Grower Name")
    # spaName = models.CharField(max_length=50, verbose_name=u"Seed Producing Agency")
    # sourceStorehouse = models.CharField(max_length=200, verbose_name=u"Source Store")
    # destiStorehouse = models.CharField(max_length=200, blank=True, null=True, verbose_name=u"Destination Store")

    # certNo = models.CharField(max_length=200, verbose_name=u"Certificate Number")
    # certDate = models.CharField(max_length=20, verbose_name=u"Certificate Date")
    # certAuthority = models.CharField(max_length=200,verbose_name=u"Certificate Authority")
    # certbytes = models.FileField(blank=True, null=True,verbose_name=u"Certificate PDF File")
    
    certNo = models.CharField(max_length=50, verbose_name=u"Certificate Number")    
    certDate = models.CharField(max_length=50, verbose_name=u"Certificate Date")    
    certAuthority= models.CharField(max_length=50, verbose_name=u"Certificate Authority")    
    # certbytes= models.CharField(max_length=50, verbose_name=u"Tag Number")    
    # certHash= models.CharField(max_length=50, verbose_name=u"Tag Number")    
    spa= models.CharField(max_length=50, verbose_name=u"SPA")    
    lotNumber= models.CharField(max_length=50, verbose_name=u"Lot Number")    
    lotQuantity= models.CharField(max_length=50, verbose_name=u"Lot Quantity")    
    status= models.CharField(max_length=50, verbose_name=u"Status")     
    attr= models.CharField(max_length=50, verbose_name=u"Attributes")    

    def __str__(self):
        return str(self.assetId)
        
    class Meta:
        managed = True

class SeedBag(models.Model):
    tagNo = models.CharField(max_length=50, verbose_name=u"Tag Number" )    
    crop = models.CharField(max_length=50, verbose_name=u"Crop Name")
    variety = models.CharField(max_length=50, verbose_name=u"Crop Variety")
    certclass = models.CharField(max_length=20, verbose_name=u"Certificate Class")
    quantity = models.CharField(max_length=20, verbose_name=u"Quantity")
    lotNumber = models.CharField(max_length=20, verbose_name=u"Lot Number")
    dateOfIssue = models.DateField(blank=True, null=True, verbose_name=u"Date of Issue")
    growerName = models.CharField(max_length=50, verbose_name=u"Grower Name")
    spaName = models.CharField(max_length=50, verbose_name=u"Seed Producing Agency")
    sourceStorehouse = models.CharField(max_length=200, verbose_name=u"Source Store")
    destiStorehouse = models.CharField(max_length=200, blank=True, null=True, verbose_name=u"Destination Store")
    certNo = models.CharField(max_length=200, blank=True, null=True, verbose_name=u"Certificate Number")    
    
    def __str__(self):
        return str(self.tagNo)
        
    class Meta:
        managed = True

class SeedBagJson(models.Model):
    jsonInput = models.CharField(max_length=20000, verbose_name=u"<b>Input Bag Details (JSON Format)</b>")
    def __str__(self):
        return str(self.jsonInput)

class SeedCertificateJson(models.Model):
    jsonInput = models.CharField(max_length=20000, verbose_name=u"<b>Input Seed Certificate Details (JSON Format)</b>")
    def __str__(self):
        return str(self.jsonInput)  

class CourtCaseJson(models.Model):
    jsonInput = models.CharField(max_length=500000,verbose_name=u"<b>Input Case Details (JSON Format)</b>")
    def __str__(self):
        return str(self.jsonInput)  
       