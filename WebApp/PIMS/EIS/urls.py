
from django.db.models import base
from django.urls import include, path
from django.contrib import admin
from EIS import views
from EIS import bc_views

urlpatterns = [
    
    # path('', views.depotstock_view, name="viewstock"),
    path('', views.login, name='login'),
    path('logout', views.logout, name='eis-logout'),
    path('admin-dashboard', views.admin_dashboard, name='admin-dashboard'),
    path('transfer-report', views.transfer_report, name='transfer-report'),
    path('bc-order-details', bc_views.bc_order_details, name='bc-order-details'),
    path('initalizestock', views.depotinitalize_view, name='initalizestock'),
    path('viewstock', views.depotstock_view, name='viewstock'),
    path('addstock', views.addstock_view, name='addstock'),
    path('dispatchstock', views.dispatchstock_view, name='dispatchstock'),
    path('depotstock_viewhistory', views.depotstock_viewhistory, name='depotstock_viewhistory'),


    path('addCertificate', views.addCertificate_view, name='addCertificate'),
    path('readCertificate', views.readCertificate_view, name='readCertificate'),
    path('updateCertificate', views.updateCertificate_view, name='updateCertificate'),    
    path('compareCertificate', views.compareCertificate, name='compareCertificate'),
    path('operateCertificate', views.operateCertificate, name='operateCertificate'),
    
    
    path('addBag', views.addBag, name='addBag'),
    path('readBag', views.readBag, name='readBag'),
    path('updateBag', views.updateBag, name='updateBag'),    
    path('transferBag', views.transferBag, name='transferBag'),
    path('operateBag', views.operateBag, name='operateBag'),
    path('casedetails', views.casedetails, name='casedetails'),
    
    path('vyapaar_loadgame', views.load_game, name='vyapaar_loadgame'),
    path('vyapaar_joingame', views.join_game, name='vyapaar_joingame'),
    path('vyapaar_loadgame/<game_id>/',views.load_game,name='vyapaar_loadgame'),
    # path('vyapaar_playgame', views.play_game, name='vyapaar_playgame'),
    path('vyapaar_creategame', views.create_game, name='vyapaar_creategame'),
    path('vyapaar_joingame/<game_id>/', views.join_game, name='vyapaar_joingame'),
    path('vyapaar_walletstatement', views.vyapaar_walletstatement, name='vyapaar_walletstatement'),
    path('vyapaar_transactiondetails', views.vyapaar_transactiondetails, name='vyapaar_transactiondetails'),
    path('vyapaar_transactiondetails/<transaction_id>/', views.vyapaar_transactiondetails, name='vyapaar_transactiondetails'),


    # path('order-details', blockchainviews.get_order_details, name='order-details'),
    # path('order_response', blockchainviews.response_order_details, name='order_response'),
    # path('create', views.EmployeeCreateView.as_view(), name='employee-create'),
    # path('login', views.user_login, name='user-login'), # Adding log-in-user instead of user-login
    # path("hello/<name>", views.hello_there, name="hello_there"),
    
]