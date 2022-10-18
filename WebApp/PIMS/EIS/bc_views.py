from django.shortcuts import render
from django.http import HttpResponse, FileResponse, HttpResponseRedirect
from .models import Employee
import re
from django.utils.timezone import datetime
from django.contrib.auth.mixins import LoginRequiredMixin,UserPassesTestMixin
from django.views.generic.edit import CreateView
from django.contrib.auth.forms import AuthenticationForm
from .forms import LoginForm, get_order_details_bc
from django.contrib.auth import authenticate, login
from django.db import connection
from django.contrib.auth.decorators import login_required
import requests 
import json
import pandas as pd
import base64
import datetime
from django.conf import settings

@login_required
def get_order_details(request):
   
    return render( request, template_name, context )

@login_required
def bc_order_details(request):
    if request.method == 'POST':
        order_key = request.POST['order_key']
        try:
            api_url= settings.BLOCKCHAIN_API_URL
            api_method="getNicOrder/"+ order_key + "/"
            api_call_str = api_url + api_method
            # api_call_str = "http://10.152.2.56:8080/api/getNicOrder/" + order_key + "/"
            response=requests.get(api_call_str, timeout=30000 )
            # print(response.status_code)
        except:
            context = {"error": True, "errorCode":"500-1", "errorText":"Gateway server request timeout"}
            template_name = 'bc_order_details_response.html'
            # return
            return render(request, template_name, context)
            
        if(response.status_code!=200):
            print ("some error")
            response_error=response.json()
            context = {"error": True, "errorCode":response_error["errorCode"], "errorText":response_error["text"]}
            template_name = 'bc_order_details_response.html'
            # return
            return render(request, template_name, context)
            
        response_text=response.json()
        # response_text={'response': '{"orders":[{"empCode":"6398","orderType":"Joining","orderNo":"(63)/2011/Pers-","OrderDate":"15/06/2011","OrderCopy":"lahu_joining.pdf","orderCopyHash":"HASH256"}]}'}
        result_dict = json.loads(response_text["response"])
        # try:
        
        for order in result_dict["orders"]:
            bytedata = order["OrderCopybytes"]
            string_data=str(bytedata)
            pdffilecontent = base64.b64decode(string_data)
            
            # response = HttpResponse(pdffilecontent, mimetype='application/pdf')
            # response['Content-Disposition'] = 'inline;filename=some_file.pdf'
            # return response
            with open('static/files/tempfiletoday.pdf', 'wb') as f:
                f.write(pdffilecontent)
                # open('tempfiletoday.pdf', 'rb')
            #return FileResponse(pdffilecontent , content_type='application/pdf')
            
           
        # except: 
        #     print ("some error")
             
             
        order1_list = json.loads(json.dumps(result_dict["orders"]))
        order1_dict = order1_list[0]  
        del order1_dict['OrderCopybytes']   
        tabel_headers=order1_dict.keys()
        table_row=order1_dict.values()     
        context = {"tabel_headers": tabel_headers, "table_row" : table_row}
        template_name='bc_order_details_response.html'
    else:
        form = get_order_details_bc() 
        context = {'form': form}
        template_name='bc_order_details.html'
    return render(request, template_name, context)
   