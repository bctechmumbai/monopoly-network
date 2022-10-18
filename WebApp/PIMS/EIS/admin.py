from django.contrib import admin
from datetime import date
import datetime
from django.utils.safestring import mark_safe
# Register your models here.
from .models import Employee, Designation, Post, Transfer, Promotion, State, District, TransferLocationType, ModeOfTransfer

# from django.contrib.admin import AdminSite
# from django.http import HttpResponse


# class MyAdminSite(AdminSite):
    
#      def get_urls(self):
#          from django.urls import path
#          urls = super().get_urls()
#          urls += [
#              path('my_view/', self.admin_view(self.my_view))
#          ]
#          return urls

#      def my_view(self, request):
#          return HttpResponse("Hello!")

# admin_site = MyAdminSite()






AGE_OF_RETIREMENT=60


def add_years(d, years):
    """Return a date that's `years` years after the date (or datetime)
    object `d`. Return the same calendar date (month and day) in the
    destination year, if it exists, otherwise use the following day
    (thus changing February 29 to March 1).

    """
    try:
        return d.replace(year = d.year + years)
    except ValueError:
        return d + (date(d.year + years, 1, 1) - date(d.year, 1, 1))


def last_day_of_month(any_day):
    next_month = any_day.replace(day=28) + datetime.timedelta(days=4)
    return next_month - datetime.timedelta(days=next_month.day)

def retirement_date_calculated(obj):
    return last_day_of_month(add_years(obj.birth_date,AGE_OF_RETIREMENT))

retirement_date_calculated.short_description = 'Retirement Date'
 
def posting (object):
    return object.place_of_Posting
posting.short_description='Place of Initial Posting'


class EmployeeAdmin(admin.ModelAdmin):
    empty_value_display = '(None)'
    list_display = ('employee_code', 'name', 'designation','post',posting,'birth_date', 'joining_date',retirement_date_calculated)
    fields = ['employee_code', 'name', ('designation', 'post'),'place_of_Posting',('birth_date', 'joining_date')]
    list_filter = ('designation','place_of_Posting','post')
    search_fields =('employee_code','name')

class DesignationAdmin(admin.ModelAdmin):
    list_display = ('designation_code','designation_name','designation_namell')
    fields = ['designation_code','designation_name','designation_namell']

class PostAdmin(admin.ModelAdmin):
    list_display = ('post_code', 'post_name', 'post_namell')
    fields = ['post_code', 'post_name', 'post_namell']

class TransferAdmin(admin.ModelAdmin):
    empty_value_display = '(None)'
    list_display = ('employee','from_type','from_location_state', 'from_location_district', 'to_type','to_location_state', 'to_location_district','transfer_order_no','transfer_order_date','relieveing_order_no','relieveing_order_date','joining_order_no', 'joining_order_date','mode_of_transfer','post_of_joining','transfer_order_copy','relieveing_order_copy','joining_order_copy','transfer_order_copy_bckey','transfer_order_copy_bc_tranid','view_bc_data' )
    fields = ['employee','mode_of_transfer',('from_type','from_location_state', 'from_location_district'), ('to_type','to_location_state', 'to_location_district'),('transfer_order_no','transfer_order_date','transfer_order_copy'),('relieveing_order_no','relieveing_order_date','relieveing_order_copy'),('joining_order_no', 'joining_order_date','joining_order_copy'),'post_of_joining']
    search_fields =('transfer_order_no','employee__name', 'employee__employee_code')
    readonly_fields = ('view_bc_data', )
    def view_bc_data(self,id):
        from django.shortcuts import redirect
        # return redirect("http://127.0.0.1:7000/eis/bc-order-details/63981")
        return mark_safe('<a href="http://127.0.0.1:8000/eis/bc-order-details"  target="_blank">View Data from Block Chain</a>')

    view_bc_data.short_description = 'view blockchain data'

class PromotionAdmin(admin.ModelAdmin):
    empty_value_display = '(None)'
    list_display = ('employee', 'from_designation', 'to_designation','order_no','order_date','promotion_date', 'place_of_joining')
    fields = ['employee', ('from_designation', 'to_designation'),('order_no','order_date'),('promotion_date', 'place_of_joining')]

class StatesAdmin(admin.ModelAdmin):
    empty_value_display = '(None)'
    list_display = ('state_code', 'state_name', 'state_namell','census_code_2001','census_code_2011')
    fields = ['state_code', ('state_name', 'state_namell'),('census_code_2001','census_code_2011'),('statetype')]

class DistrictAdmin(admin.ModelAdmin):
    empty_value_display = '(None)'
    list_display = ('district_code', 'district_name', 'district_namell','census_code_2001','census_code_2011','state')
    fields = ['district_code', ('district_name', 'district_namell'),('census_code_2001','census_code_2011'),('state')]
    list_filter = ('state',)
   
admin.site.register(Employee, EmployeeAdmin)
admin.site.register(Transfer, TransferAdmin)
admin.site.register(Designation,DesignationAdmin)
admin.site.register(Post,PostAdmin)
admin.site.register(Promotion, PromotionAdmin)
# admin.site.register(State, StatesAdmin)
# admin.site.register(District, DistrictAdmin)
# admin.site.register(TransferLocationType)
# admin.site.register(ModeOfTransfer)#