from django import forms
from django.forms import ModelForm
from .models import *

class DateInput(forms.DateInput):
    input_type = 'date'

class LoginForm(forms.Form):
    login_email = forms.EmailField()
    #login_pwd = forms.PasswordField()

class get_order_details_bc(forms.Form):    
    #order_key=forms.CharField(label='Order Key', max_length=255,required=True)
    order_key=forms.CharField(widget=forms.TextInput(attrs={'class': 'form-control'}))  

# Create the form class.
class DepotForm(ModelForm):
     class Meta:
         model = BeDepot
         fields = "__all__"

class DepotStockViewForm(ModelForm):
     class Meta:
         model = BeDepot
         fields = ('depot_code',)
class DepotStockUpdateForm (ModelForm):
     class Meta:
         model = BeDepot
         fields = ('depot_code','scheme_code','commodity_code','quantity')     

class SeedCertificateForm(ModelForm):
     class Meta:
         model = SeedCertificate
         fields = "__all__" 

         widgets = {
            'CertDate': forms.TextInput(attrs={'type' : 'date'}),
                        #TextInput(attrs={'class': 'special'})
        } 

# class SeedForm(forms.Form):
#     assetId = forms.CharField(max_length=50) 
#     LotNumber = forms.CharField(max_length=20)
#     certbytes = forms.FileField()

class SeedCertificateViewForm(ModelForm):
     class Meta:
         model = SeedCertificate
         fields = ('certNo','lotNumber')   
class SeedCertificateCompareForm(ModelForm):
     class Meta:
         model = SeedCertificate
         fields = ('certNo','lotNumber')  
         
class SeedBagForm(ModelForm):
     class Meta:
         model = SeedBag
         fields = "__all__"      
         
class SeedBagViewForm(ModelForm):
    class Meta:
         model = SeedBag
         fields =  ('tagNo','lotNumber')
         
class SeedBagTransferForm(ModelForm):
    class Meta:
         model = SeedBag
         fields =  ('tagNo','lotNumber','destiStorehouse')    
         

class SeedBagJsonForm(ModelForm):
    class Meta:
         model = SeedBagJson
         fields = "__all__" 
         widgets = { 'jsonInput': forms.Textarea(attrs={'rows': 10}) }

class SeedCertificateJsonForm(ModelForm):
    class Meta:
         model = SeedCertificateJson
         fields = "__all__" 
         widgets = { 'jsonInput': forms.Textarea(attrs={'rows': 10}) }

class CourtCaseJsonForm(ModelForm):
    class Meta:
         model = CourtCaseJson
         fields = "__all__" 
         widgets = { 'jsonInput': forms.Textarea(attrs={'rows': 10}) }


                                    
