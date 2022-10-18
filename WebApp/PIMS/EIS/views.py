from logging import NullHandler
from operator import index
import sys,os
import base64
import traceback
import json
from urllib.request import Request
from django.shortcuts import render
from django.http import HttpResponse
from pandas.core.frame import DataFrame
# from .models import Employee
import re
from django.utils.timezone import datetime
from django.http import HttpResponseRedirect
from django.contrib.auth.mixins import LoginRequiredMixin, UserPassesTestMixin
from django.views.generic.edit import CreateView
from django.contrib.auth.forms import AuthenticationForm
from .forms import LoginForm
from django.contrib.auth import authenticate, login
from django.contrib import auth
from django.db import connection
from django.contrib.auth.decorators import login_required
from django.http import HttpResponse
import requests
from .forms import *
import pandas as pd
import numpy as np
from django.conf import settings
import hashlib
import base64
from django.utils.safestring import mark_safe
from django.http import FileResponse
import datetime

# Create your views here.

cols = 10
rows = 10
currentpos = 0
df = pd.DataFrame(index=np.arange(10),columns=np.arange(10))
df = df.fillna('') 

locationplace = []
current_player = 0
locations = []

def load_board(request):
    counter = 0
    try:
        # df = pd.DataFrame(index=np.arange(10), columns=np.arange(10))
        # df = df.fillna('') 
        col=0
        for row in range(0,rows):
            locationplace.append([row,col])
            df[row][col] = str(row) + str(col) + "," + str(counter)
            counter = counter + 1 
        
        row= rows -1
        for col in range(1, cols):
            locationplace.append([row,col])
            df[row][col] = str(row) + str(col) + "," + str(counter)
            counter = counter + 1 
        
        col= cols-1
        for row in range(rows-2,-1,-1):
            locationplace.append([row,col])
            df[row][col] = str(row) + str(col) + "," + str(counter)
            counter = counter + 1 
        
        row= 0
        for col in range(cols-2,0,-1):
            locationplace.append([row,col])
            df[row][col] = str(row) + str(col) + "," + str(counter)
            counter = counter + 1 

        headers = {'content-type': 'application/json'}
        headers['x-access-token'] = request.session.get('x-access-token')        
        api_url = settings.VYAPAR_API_URL
        api_method = "getlocations"
        api_call_str = api_url + api_method
        print(api_call_str)
        response = requests.post(
            api_call_str, headers=headers, timeout=30000)
        
        locationdata = response.json()
        counter = 0
        for assets in  locationdata["data"]:
            row = locationplace[counter][0]
            col = locationplace[counter][1]
            locations.append(assets)
            counter = counter + 1
            table = '<table>' #style="border: 1px solid ' + assets["assetData"]["placeColor"] +';"
            forecolor = "black"
            if 'placeColor' not in  assets["assetData"]:
                table += "<tr><th>"
            else:
                if assets["assetData"]["placeColor"] == "Blue" or assets["assetData"]["placeColor"] == "Brown":
                    forecolor = "white"
                table += "<tr><th bgcolor=" +  assets["assetData"]["placeColor"] + ">"
            table += "<font color=" + forecolor + ">" + assets["assetData"]["placeName"] + "</font>"
            table += "</th></tr>"
            table += "<tr><td>"
            table += '<img width="80px" height="80px" src="data:image/png;base64,' + assets["assetData"]["placeImage"] + '">'
            table += "</td></tr>"
            table += "<tr><td>"
            table += "Cost : " + assets["assetData"]["placeCost"] + "<br />"
            table += "Rent : " + assets["assetData"]["placeRent"] + "<br />"
            # table += "Owner : " + assets["assetData"]["placeCost"] + "<br />"
            table += "</td></tr>"
            table += '</table>'
            # print(table)
            df[row][col] = table
        
         
        
        
    except:
        return {"error": True, "errorCode": "500-1",
                             "errorText": "error :" + str(traceback.print_exc())}

def read_current_game(request,game_id):
    headers = {'content-type': 'application/json'}
    headers['x-access-token'] = request.session.get('x-access-token')        
    api_url = settings.VYAPAR_API_URL
    if(game_id is None):
        s = {
        "assetId":"9620220161"
        }
    else:
        s = {
        "assetId":game_id
        }
    jsondata = json.dumps(s)
    api_method = "getAsset"
    api_call_str = api_url + api_method
    print(api_call_str)
    return requests.post(api_call_str, data=jsondata, headers=headers, timeout=30000)

def getvyapargames(request):
    headers = {'content-type': 'application/json'}
    headers['x-access-token'] = request.session.get('x-access-token')        
    api_url = settings.VYAPAR_API_URL
    
    api_method = "getgames"
    api_call_str = api_url + api_method
    response = requests.post(
            api_call_str, headers=headers, timeout=30000)
    res = response.json()
    if(res["status"] == "Success"):
        print(request.session.get("user"))
        games_notjoined = []
        games_joined = []
        games_closed = []
        print(request.session.get("user"))
        for game in res["data"]:
            joined = False
            game_closed = False
            if game["assetData"]["closed"] == True:
                game_closed = True
            for player in game["assetData"]["players"]:
                userId = player["userId"] 
                if(userId == request.session.get("user")):
                    joined = True
                    break                    
            if joined == False:
                if game_closed == False:
                    games_notjoined.append("<a href = 'vyapaar_joingame/"+str(game["assetData"]["assetId"]) + "/' class='btn btn-success'>" + str(game["assetData"]["assetId"]) + ",  Players (" + str(len(game["assetData"]["players"])) + ")</a>") 
            if joined == True:
                if game_closed == True:
                    games_closed.append("<a href = 'vyapaar_loadgame/"+str(game["assetData"]["assetId"]) + "/' class='btn btn-danger'>" + str(game["assetData"]["assetId"]) + ",  Players (" + str(len(game["assetData"]["players"])) + ")</a>") 
                else:
                    games_joined.append("<a href = 'vyapaar_loadgame/"+str(game["assetData"]["assetId"]) + "/' class='btn btn-primary'>" + str(game["assetData"]["assetId"]) + ",  Players (" + str(len(game["assetData"]["players"])) + ")</a>") 
    
        return  games_joined, games_notjoined, games_closed 
    else:
        return res["data"], res["data"], res["data"]
    # return df_game.to_html(classes="table table-bordered table_hover table-responsive",escape=False,index=False,header=False)
     
def join_game(request,game_id):
    context = {}
    try:
        headers = {'content-type': 'application/json'}
        headers['x-access-token'] = request.session.get('x-access-token')        
        api_url = settings.VYAPAR_API_URL
        api_method = "joingame"
        s = {
            "gameId":game_id
        }
        jsondata = json.dumps(s)
        
        # print(jsondata)
        api_call_str = api_url + api_method
        
        response = requests.post(
            api_call_str, data=jsondata, headers=headers, timeout=30000)
       
        res = response.json()
        game=res["data"]["game"]
        # print(res);
        return load_game(request,game_id)
        # if(res["status"] == "Success"):
        #     return load_game(request,game_id)
        # else
    
    except:
        context['output'] = {"error": True, "errorCode": "500-1",
                             "errorText": "error :" + str(traceback.print_exc())}
    # context['form'] = form
    return render(request, "vyapaar_loadgame.html",context) 


def load_game(request,game_id):
    
    context = {}
    try:
        if request.method == 'POST':
            if 'btnEnd' in request.POST:
                s = { "gameId":game_id }
                api_method = "endgame"
            if 'btnPurchase' in request.POST:
                locationAssetId = request.POST["currentPlace"]
                s = { "gameId":game_id, "locationAssetId": locationAssetId }
                api_method = "purchaselocation"
            if 'btnPlay' in request.POST:
                s = { "gameId":game_id }
                api_method = "playgame"
            
            headers = {'content-type': 'application/json'}
            headers['x-access-token'] = request.session.get('x-access-token')        
            api_url = settings.VYAPAR_API_URL
            api_call_str = api_url + api_method
            print(api_call_str)
            jsondata = json.dumps(s)
            response = requests.post(api_call_str, data=jsondata, headers=headers, timeout=30000)
            movedata = response.json()  
            if movedata["status"] == "Error":
                gamedata = read_current_game(request,game_id).json()["data"]["assetData"]                
                context["error"] = movedata["data"]["errorMessage"]
                # return render(request, "vyapaar_loadgame.html", context)    
            if movedata["status"] == "Success":
                gamedata = movedata["data"]["game"] 
                context["bcmsg"] =  movedata["data"]["transactionMessage"]
        else:
            gamedata = read_current_game(request,game_id).json()["data"]["assetData"]
        
        
        load_board(request)
        context['game_id'] = game_id
        context['gameDateTime'] = gamedata["gameDateTime"]
        if gamedata["createdBy"] == request.session.get("user"):
            context['endgame'] = '<button type="submit" class="btn btn-danger" name="btnEnd" id="btnEnd">End Game</button>'
        
        context["closed"] = gamedata["closed"]
        context["winner"] = gamedata["winner"]
        
        current_player = int(gamedata["nextMove"])
        
        print(current_player)
        placesowned = []
        loccounter = 0
        for loc in gamedata["locations"]:
            if loc["placeOwner"] == request.session.get("user"):
                placesowned.append("<span class='text-primary'>" + loc["placeName"] + '. ' + "</span>")
            bl = locationplace[loccounter]
            row = bl[0]
            col = bl[1]
            if loc["placeOwner"] != "":
                df[row][col] = df[row][col] + "Owner : " + loc["placeOwner"][0:loc["placeOwner"].find("@")]  + "<br />"
            loccounter = loccounter + 1
        
        
        players = []
        for player in gamedata["players"]:
            playSequence = player["playSequence"] 
            playerId = player["userId"] 
            currentPlace = player["currentPlace"] 
                
            if(playSequence == current_player):
                # players.append("<span class='text-primary'>" + str(playSequence) + '. ' + playerId + "</span>")
                players.append('<div style="background-color:green;">' + str(playSequence) + '. ' + playerId + "</div>")        
            else:
                players.append(str(playSequence) + '. ' + playerId)
            
            if (playerId == request.session.get("user")):
                walletBalance = player["walletBalance"]
                context['walletBalance'] = walletBalance
                for loc in locations:
                    
                    if(loc["assetData"]["assetId"] == currentPlace):
                        context['player_current_location'] = loc["assetData"]["placeName"]
                        context['current_location_cost'] = loc["assetData"]["placeCost"]
                        context['current_location_rent'] = loc["assetData"]["placeRent"]
                        context['currentPlace'] = currentPlace
                        break
            loccounter = 0
            for loc in gamedata["locations"]:
                if currentPlace == loc["assetId"]:
                    bl = locationplace[loccounter]
                    row = bl[0]
                    col = bl[1]
                    df[row][col] = df[row][col] + '<i class="fa fa-user"></i> ' + playerId[0:playerId.find("@")] + "<br />"
                loccounter = loccounter + 1
        
               
        # player_position = locationplace[int(player["currentPlace"]["place"]) - 1]
        # row = player_position[0]
        # col = player_position[1]
        # df[row][col] = df[row][col] +"<br />" + player["userId"]
        df_placesowned = pd.DataFrame(placesowned)
        df_html = df_placesowned.to_html(classes="table table-bordered table_hover table-responsive",escape=False,index=False,header=False)
        context['placesowned'] = df_html
        df_players = pd.DataFrame(players)
        df_html = df_players.to_html(classes="table table-bordered table_hover table-responsive",escape=False,index=False,header=False)
        context['players'] = df_html
        df_html = df.to_html(classes="table  table_hover table-responsive",escape=False,index=False,header=False)
        context['gameboard'] = df_html 
        
    except Exception as e:
        context['error'] = str(e)
    # context['form'] = form
    return render(request, "vyapaar_loadgame.html", context)    

def create_game(request):
    context = {}
    try:
        headers = {'content-type': 'application/json'}
        headers['x-access-token'] = request.session.get('x-access-token')        
        api_url = settings.VYAPAR_API_URL
        api_method = "creategame"
        api_call_str = api_url + api_method
        
        
        response = requests.post(
            api_call_str, headers=headers, timeout=30000)
        
        res = response.json()
        if(res["status"] == "Success"):
            game_id = res["data"]["assetId"]
            # game=res["data"]["game"]
            # print(res["data"])
            return load_game(request,game_id)
            # load_board(request) 
            # df_html = df.to_html(classes="table table-bordered table_hover table-responsive",escape=False,index=False,header=False)
            # context['gameboard'] = df_html
            
            # gamedata = read_current_game(request,game_id=game_id).json()            
            # current_player = int(gamedata["data"]["assetData"]["nextMove"])

            # players = []
            # for player in gamedata["data"]["assetData"]["players"]:
            #     if(player["playSequence"] == current_player):
            #         players.append("<span class='text-primary'>" + str(player["playSequence"]) + player["emailId"] + "</span>")    
            #     else:
            #         players.append(str(player["playSequence"]) + player["emailId"])
            
            # df_players = pd.DataFrame(players)
            # request.session['df_players'] = df_players.to_json()
            # print(df_players)
            # df_html = df_players.to_html(classes="table table-bordered table_hover table-responsive",escape=False,index=False,header=False)
            # context['players'] = df_html
        else:
             context["error"] = res["data"]["errorMessage"]
    except:
        context['output'] = {"error": True, "errorCode": "500-1",
                             "errorText": "error :" + str(traceback.print_exc())}
    return render(request, "vyapaar_loadgame.html", context) 

def vyapaar_walletstatement(request):
    context = {}
    context["user"] = request.session.get("user")
    try:
        headers = {'content-type': 'application/json'}
        headers['x-access-token'] = request.session.get('x-access-token')        
        api_url = settings.VYAPAR_API_URL
        api_method = "getWalletStatement"
        api_call_str = api_url + api_method
        s = { "userId":request.session.get("user") }
        jsondata = json.dumps(s)
        response = requests.post(api_call_str,data=jsondata ,headers=headers, timeout=30000)        
        res = response.json()
        if(res["status"] == "Success"):            
            transaction_details = []            
            pd_transactions = pd.DataFrame(res["data"]["transactions"])
            pd_transactions = pd_transactions.sort_values(by='Transactiondttm',ascending=False,na_position='first')
            for td in res["data"]["transactions"]:                
                transaction_details.append(json.loads(td["Transactiondata"]))              
            pd_transactions_details = pd.DataFrame(transaction_details)
            pd_td  = pd.concat([pd_transactions, pd_transactions_details], axis=1, join='inner')
            # pd_td["tranactionType"] = pd_td["tranactionType"].str.upper()
            pd_td["Transactiondttm"] = pd.to_datetime(pd_td["Transactiondttm"]).dt.tz_convert(tz='Asia/Kolkata')
            pd_td["Transactiondttm"] = pd.to_datetime(pd_td["Transactiondttm"]).dt.strftime('%d-%m-%Y %I:%M %p')
            
             
            pd_td["TransactionId"] = "<a href = 'vyapaar_transactiondetails/"+pd_td["TransactionId"] + "/'>" + pd_td["TransactionId"] + "</a>"
            
            pd_td["Credit"] = np.where(pd_td['tranactionType'] == 'Cr', pd_td['transactionAmount'], "")
            pd_td["Debit"] = np.where(pd_td['tranactionType'] == 'Dr', pd_td['transactionAmount'], "")
            
            pd_td = pd_td[["Transactiondttm","transactionDetails","Credit","Debit","walletbalance","TransactionId"]]            
            context['currentbalance'] = pd_td.iloc[0]["walletbalance"]
            pd_td.columns = ["Transaction Date Time   ","Details", "Credit","Debit" ,"Balance","Transaction Id"]
            df_html = pd_td.to_html(classes="table table-bordered table_hover table-responsive ",escape=False,index=False)
            
            context['transactions'] = df_html
        else:
            context["error"] = res["data"]["errorMessage"]        
    except:
        context['output'] = {"error": True, "errorCode": "500-1",
                             "errorText": "error :" + str(traceback.print_exc())}
    return render(request, "vyapaar_walletstatement.html", context) 

def vyapaar_transactiondetails(request,transaction_id):
    context = {}
    
    context["user"] = request.session.get("user")
    try:
        context["transaction_id"] = transaction_id
        headers = {'content-type': 'application/json'}
        headers['x-access-token'] = request.session.get('x-access-token')        
        api_url = settings.VYAPAR_API_URL
        api_method = "getTransactionDetails"
        api_call_str = api_url + api_method
        s = { "txid":transaction_id }
        jsondata = json.dumps(s)
        response = requests.post(api_call_str,data=jsondata ,headers=headers, timeout=30000)        
        res = response.json()        
        print(res["data"].keys())
        if(res["status"] == "Success"):                        
            pd_keys = pd.DataFrame(res["data"].keys())
            pd_values = pd.DataFrame(res["data"].values())
            pd_td = pd.concat([pd_keys, pd_values], axis=1, join='inner')
            pd_td.columns = ["Key", "Value"]
            df_html = pd_td.to_html(classes="table table-bordered table_hover table-responsive",escape=False,index=False)
            context['transaction_details'] = df_html        
    except:
        context['output'] = {"error": True, "errorCode": "500-1",
                             "errorText": "error :" + str(traceback.print_exc())}
    return render(request, "vyapaar_transactiondetails.html", context) 


def admin_dashboard(request):
    context = {}
    context["user"] = request.session.get("user")
    gamejoined,gamenotjoined,vyaparclosedgames = getvyapargames(request)
    df_gamejoined = pd.DataFrame(gamejoined)
    df_gamenotjoined = pd.DataFrame(gamenotjoined)
    df_vyaparclosedgames = pd.DataFrame(vyaparclosedgames)
    
    context["vyaparjoinedgames"] = df_gamejoined.to_html(classes="table table-bordered table_hover table-responsive",escape=False,index=False,header=False)
    context["vyapargames"] = df_gamenotjoined.to_html(classes="table table-bordered table_hover table-responsive",escape=False,index=False,header=False)
    context["vyaparclosedgames"] = df_vyaparclosedgames.to_html(classes="table table-bordered table_hover table-responsive",escape=False,index=False,header=False)
    return render(request, 'admin_dashboard.html', context=context)
    

























def addstock_view(request):
    context = {}
    try:
        form = DepotStockUpdateForm(request.POST)
        if form.is_valid():
            bcmsg = 'The data is stored to MHBCN Blockchain Network'
            depot_code = request.POST['depot_code']
            commodityCode = request.POST['commodity_code']
            schemeCode = request.POST['scheme_code']
            quantity = request.POST['quantity']
            depotCode = depot_code + schemeCode + commodityCode
            s = {"depotCode": depotCode,
                 "quantity": quantity}
            headers = {'content-type': 'application/json'}

            headers['x-access-token'] = request.session.get('x-access-token')
            # headers[settings.API_KEY] = settings.API_KEY_VALUE
            jsondata = json.dumps(s)

            api_url = settings.BLOCKCHAIN_API_URL
            api_method = "addstock/"
            api_call_str = api_url + api_method
            print(api_call_str)
            print(jsondata)
            # api_call_str = "http://10.152.2.56:8080/api/getNicOrder/" + order_key + "/"
            response = requests.post(
                api_call_str, data=jsondata, headers=headers, timeout=30000)
            print(response.status_code)
            print(str(response))
            #api = "http://10.152.2.120/api/depotmanager/addstock/"
            #response=requests.get(api, timeout=30000)
            if response.status_code == 200:  # SUCCESS
                s1 = response.json()
                print(s1)
                s = json.loads(str(s1))
                print(s)
                if str(s['status']) == "Success":
                    t = [s['data']]
                    pd_s = pd.DataFrame.from_dict(t)
                    pd_s = pd_s.T
                    print(pd_s)
                    context['output'] = pd_s.to_html(
                        classes='table table-bordered')
                    context['bcmsg'] = bcmsg
                else:
                    t = [s['data']]
                    pd_s = pd.DataFrame.from_dict(t)
                    pd_s = pd_s.T
                    print(pd_s)
                    context['output'] = pd_s.to_html(
                        classes='table table-bordered text-danger')
            else:
                if response.status_code == 404:  # NOT FOUND
                    pd_s = pd.DataFrame([0], columns=['Not Found'])
                else:
                    pd_s = pd.DataFrame([0], columns=[response.status_code])
                context['output'] = pd_s.to_html(
                    classes='table table-bordered text-danger')
        else:
            print("Invalid Form")
    except:
        context['output'] = {"error": True, "errorCode": "500-1",
                             "errorText": "error :" + str(traceback.print_exc())}
    context['form'] = form
    return render(request, "addstockdepot.html", context)




def dispatchstock_view(request):
    context = {}
    try:
        form = DepotStockUpdateForm(request.POST)
        if form.is_valid():
            bcmsg = 'The data is saved to MHBCN Blockchain Network'
            depot_code = request.POST['depot_code']
            commodityCode = request.POST['commodity_code']
            schemeCode = request.POST['scheme_code']
            quantity = request.POST['quantity']
            depotCode = depot_code + schemeCode + commodityCode
            s = {"depotCode": depotCode,
                 "quantity": quantity}
            headers = {'content-type': 'application/json'}
            headers['x-access-token'] = request.session.get('x-access-token')
            # headers[settings.API_KEY] = settings.API_KEY_VALUE
            jsondata = json.dumps(s)

            api_url = settings.BLOCKCHAIN_API_URL
            api_method = "dispatchstock/"
            api_call_str = api_url + api_method
            print(api_call_str)
            print(jsondata)
            # api_call_str = "http://10.152.2.56:8080/api/getNicOrder/" + order_key + "/"
            response = requests.post(
                api_call_str, data=jsondata, headers=headers, timeout=30000)
            print(response.status_code)
            print(str(response))
            #api = "http://10.152.2.120/api/depotmanager/addstock/"
            #response=requests.get(api, timeout=30000)
            if response.status_code == 200:  # SUCCESS
                s1 = response.json()
                print(s1)
                s = json.loads(str(s1))
                print(s)
                if str(s['status']) == "Success":
                    t = [s['data']]
                    pd_s = pd.DataFrame.from_dict(t)
                    pd_s = pd_s.T
                    print(pd_s)
                    context['output'] = pd_s.to_html(
                        classes='table table-bordered')
                    context['bcmsg'] = bcmsg
                else:
                    t = [s['data']]
                    pd_s = pd.DataFrame.from_dict(t)
                    pd_s = pd_s.T
                    print(pd_s)
                    context['output'] = pd_s.to_html(
                        classes='table table-bordered text-danger')
            else:
                if response.status_code == 404:  # NOT FOUND
                    pd_s = pd.DataFrame([0], columns=['Not Found'])
                else:
                    pd_s = pd.DataFrame([0], columns=[response.status_code])
                context['output'] = pd_s.to_html(
                    classes='table table-bordered text-danger')
        else:
            print("Invalid Form")
    except:
        context['output'] = {"error": True, "errorCode": "500-1",
                             "errorText": "error :" + str(traceback.print_exc())}
    context['form'] = form
    return render(request, "dispatchtockdepot.html", context)


def depotinitalize_view(request):

    context = {}
    # create object of form
    try:
        form = DepotForm(request.POST)
        if form.is_valid():
            bcmsg = 'The data is saved to MHBCN Blockchain Network'
            depot_code = request.POST['depot_code']
            depot_name = request.POST['depot_name']
            commodityCode = request.POST['commodity_code']
            commodityName = request.POST['commodity_name']
            schemeCode = request.POST['scheme_code']
            schemeName = request.POST['scheme_name']
            quantity = request.POST['quantity']
            s = {"depotCode":  depot_code,
                 "depotName":  depot_name,
                 "schemeCode": schemeCode,
                 "schemeName": schemeName,
                 "commodityCode": commodityCode,
                 "commodityName": commodityName,
                 "quantity": quantity}
            headers = {'content-type': 'application/json'}
            headers['x-access-token'] = request.session.get('x-access-token')
            # headers[settings.API_KEY] = settings.API_KEY_VALUE
            jsondata = json.dumps(s)
            api_url = settings.BLOCKCHAIN_API_URL
            api_method = "initializedepot/"
            api_call_str = api_url + api_method
            print(api_call_str)
            print(jsondata)
            # api_call_str = "http://10.152.2.56:8080/api/getNicOrder/" + order_key + "/"
            response = requests.post(
                api_call_str, data=jsondata, headers=headers, timeout=30000)
            print(response.status_code)
            print(str(response))
            if response.status_code == 200:  # SUCCESS
                s1 = response.json()
                print(s1)
                s = json.loads(str(s1))
                print(s)
                if str(s['status']) == "Success":
                    t = [s['data']]
                    pd_s = pd.DataFrame.from_dict(t)
                    pd_s = pd_s.T
                    print(pd_s)
                    context['output'] = pd_s.to_html(
                        classes='table table-bordered')
                    context['bcmsg']=bcmsg
                else:
                    t = [s['data']]
                    pd_s = pd.DataFrame.from_dict(t)
                    pd_s = pd_s.T
                    print(pd_s)
                    context['output'] = pd_s.to_html(
                        classes='table table-bordered text-danger')
                
            else:
                if response.status_code == 404:  # NOT FOUND
                    pd_s = pd.DataFrame([0], columns=['Not Found'])
                else:
                    pd_s = pd.DataFrame([0], columns=[response.status_code])
                
                context['output'] = pd_s.to_html(
                    classes='table table-bordered text-danger')
                
        else:
            print("invalid form")
    except:
        context = {"error": True, "errorCode": "500-1",
                   "errorText": "error :" + str(traceback.print_exc())}
    context['form'] = form
    return render(request, "initalizestockdepot.html", context)


def depotstock_view(request):
    context = {}

    # create object of form
    form = DepotStockViewForm(request.POST or None)
    # check if form data is valid
    if form.is_valid():
        # save the form data to model
        try:
            bcmsg = 'The data is fetch from MHBCN Blockchain Network'
            depot_code = request.POST['depot_code']
            api_url = settings.BLOCKCHAIN_API_URL
            api_method = "getstock/"
            api_call_str = api_url + api_method + depot_code
            print(api_call_str)
            #api = "http://10.152.2.120/api/depotmanager/getstock/" + depot_code
           # headers = {"Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNjM4OTQxNjUzLCJpYXQiOjE2Mzg5NDA0NTMsImp0aSI6IjRkZGQyNjdlYzIyNDRiZTY5OGZhMjljNjAwNjk3MjE4IiwidXNlcl9jb2RlIjoiRDQ3NDAwMDEiLCJ1c2VybmFtZSI6ImRzb2RodWxlIiwidXNlcl90eXBlIjoiRFNPIiwidXNlcl9yb2xlIjoiMDIiLCJzdGF0ZV9jb2RlIjoiMjciLCJkaXN0X2NvZGUiOiI0NzQiLCJ0YWx1a2FfY29kZSI6bnVsbCwiZGVwb3RfY29kZSI6bnVsbCwiZnBzX2NvZGUiOm51bGx9.XKso7219sYk1mbSDFKcaOnXCw9AL3r5tsQaOlTUbRoM"}
            headers = {'content-type': 'application/json'}
            headers['x-access-token'] = request.session.get('x-access-token')
            response = requests.get(api_call_str,headers=headers, timeout=30000)
            print(str(response))
            if response.status_code == 200:  # SUCCESS
                s1 = response.json()
                print(s1)
                s = json.loads(str(s1))
                print(s)
                if str(s['status']) == "Success":
                    print(type(s['data']))
                    t = json.loads(s['data'])
                    t = [t]
                    pd_s = pd.DataFrame.from_dict(t)
                    pd_s = pd_s.T
                    print(pd_s)
                    context['output'] = pd_s.to_html(
                        classes='table table-bordered')
                    context['bcmsg'] = bcmsg
                else:
                    t = [s['data']]
                    pd_s = pd.DataFrame.from_dict(t)
                    pd_s = pd_s.T
                    print(pd_s)
                    context['output'] = pd_s.to_html(
                        classes='table table-bordered text-danger')
            else:
                if response.status_code == 404:  # NOT FOUND
                    pd_s = pd.DataFrame([0], columns=['Not Found'])
                else:
                    pd_s = pd.DataFrame([0], columns=[response.status_code])
                context['output'] = pd_s.to_html(
                    classes='table table-bordered text-danger')
            #context['output'] = pd_s.to_html(classes='table table-bordered',index=False)
            
        except:
            context['output'] = {"error": True, "errorCode": "500-1",
                                 "errorText": "error :" + str(traceback.print_exc())}
            # return render(request, "viewstockdepot.html", context)
    context['form'] = form
    return render(request, "viewstockdepot.html",  context)

def depotstock_viewhistory(request):
    context = {}

    # create object of form
    form = DepotStockViewForm(request.POST or None)
    # check if form data is valid
    if form.is_valid():
        # save the form data to model
        try:
            bcmsg = 'The data is fetch from MHBCN Blockchain Network'
            depot_code = request.POST['depot_code']
            api_url = settings.BLOCKCHAIN_API_URL
            api_method = "getstockhistory/"
            api_call_str = api_url + api_method + depot_code
            print(api_call_str)
            headers = {'content-type': 'application/json'}
            headers['x-access-token'] = request.session.get('x-access-token')
            response = requests.get(api_call_str,headers=headers, timeout=30000)
            print(str(response))
            if response.status_code == 200:  # SUCCESS
                s1 = response.json()
                print(s1)
                s = json.loads(str(s1))
                print(s)
                if str(s['status']) == "Success":
                    t = s['data']
                    pd_s = pd.DataFrame.from_dict(t)
                    #pd_s['Value'] = pd.DataFrame.from_dict([pd_s['Value']]).to_html(classes='table table-bordered')
                    print(pd_s)
                    context['output'] = pd_s.to_html(
                        classes='table table-bordered')
                    context['bcmsg'] = bcmsg
                else:
                    t = [s['data']]
                    pd_s = pd.DataFrame.from_dict(t)
                    pd_s = pd_s.T
                    print(pd_s)
                    context['output'] = pd_s.to_html(
                        classes='table table-bordered text-danger')
            else:
                if response.status_code == 404:  # NOT FOUND
                    pd_s = pd.DataFrame([0], columns=['Not Found'])
                else:
                    pd_s = pd.DataFrame([0], columns=[response.status_code])
                context['output'] = pd_s.to_html(
                    classes='table table-bordered text-danger')
            
        except:
            context['output'] = {"error": True, "errorCode": "500-1",
                                 "errorText": "error :" + str(traceback.print_exc())}
            # return render(request, "viewstockdepot.html", context)
    context['form'] = form
    return render(request, "stockhistory.html",  context)

def addCertificate_view(request):
    context = {}
    if not request.session.get('x-access-token', None):
        return render(request, "login.html",  context)    
    # create object of form
    if request.method == 'POST':
        form = SeedCertificateForm(request.POST, request.FILES)
        # check if form data is valid
        if form.is_valid():
            # save the form data to model
            try:
                bcmsg = 'The data stored in MHBCN Blockchain Network'
                print(type(request.POST))
                print(request.FILES)
                api_url = settings.API_URL + "seedChain/"
                api_method = "createCertificate/"
                api_call_str = api_url + api_method
                print(api_call_str)
                # certfile = request.FILES['certbytes']
                # cert_content_bytes = certfile.file.read()

                s = request.POST
                s = s.dict()
                del s['csrfmiddlewaretoken']  # to remove extra form post form data
                # s['certbytes'] = base64.b64encode(cert_content_bytes).decode('utf-8')
                # s['certHash'] = hashlib.sha256(cert_content_bytes).hexdigest()

                print(s)
                headers = {'content-type': 'application/json'}
                headers['x-access-token'] = request.session.get('x-access-token')
                jsondata = json.dumps(s)

                response = requests.post(
                    api_call_str, data=jsondata, headers=headers, timeout=30000)
                print(str(response))
                if response.status_code == 200:  # SUCCESS
                    s1 = response.json()
                    print(s1)
                    s = json.loads(str(s1))
                    print(s)
                    if str(s['status']) == "Success":
                        print(type(s['data']))
                        t = s['data']
                        t = [t]
                        pd_s = pd.DataFrame.from_dict(t)
                        pd_s = pd_s.T
                        print(pd_s)
                        context['output'] = pd_s.to_html(
                            classes='table table-bordered')
                    else:
                        t = [s['data']]
                        pd_s = pd.DataFrame.from_dict(t)
                        pd_s = pd_s.T
                        print(pd_s)
                        context['output'] = pd_s.to_html(
                            classes='table table-bordered text-danger')
                else:
                    if response.status_code == 404:  # NOT FOUND
                        pd_s = pd.DataFrame([0], columns=['Not Found'])
                    else:
                        pd_s = pd.DataFrame([0], columns=[response.status_code])
                    context['output'] = pd_s.to_html(
                        classes='table table-bordered text-danger')
                #context['output'] = pd_s.to_html(classes='table table-bordered',index=False)
                context['bcmsg'] = bcmsg
            except:
                context['output'] = {"error": True, "errorCode": "500-1",
                                    "errorText": "error :" + str(traceback.print_exc())}
                # return render(request, "viewstockdepot.html", context)        
    else:
        form = SeedCertificateForm()
    context['form'] = form    
    return render(request, "addcertificate.html",  context)

def readCertificate_view(request):
    context = {}
    if not request.session.get('x-access-token', None):
        return render(request, "login.html",  context)    
    # create object of form
    if request.method == 'POST':
        form = SeedCertificateViewForm(request.POST)
        # check if form data is valid
        if form.is_valid():
            # save the form data to model
            try:
                bcmsg = 'The data is fetch from MHBCN Blockchain Network'
                assetId = request.POST['certNo']
                LotNumber = request.POST['lotNumber']
                api_url = settings.API_URL + "seedChain/"
                if 'btnViewHistory' in request.POST:
                    api_method = "getCertificateHistory/"
                else:
                    api_method = "readCertificate/"
                api_call_str = api_url + api_method
                s = {
                    "certNo":  assetId,
                    "lotNumber":  LotNumber
                }
                headers = {'content-type': 'application/json'}
                headers['x-access-token'] = request.session.get('x-access-token')
                jsondata = json.dumps(s)

                response = requests.post(
                    api_call_str, data=jsondata, headers=headers, timeout=30000)
                print(str(response))
                if response.status_code == 200:  # SUCCESS
                    s1 = response.json()
                    print(s1)
                    s = json.loads(str(s1))
                    print(s)
                    if str(s['status']) == "Success":
                        print(type(s['data']))
                        if 'btnViewHistory' in request.POST:
                            t = s['data']  
                            pd_s = pd.DataFrame.from_dict(t)                                             
                        else:
                            t = json.loads(s['data'])
                            # bytedata = t['certbytes']
                            # string_data=str(bytedata)
                            # pdffilecontent = base64.b64decode(string_data)                                    
                            # with open('static/files/tempfiletoday.pdf', 'wb') as f:
                            #     f.write(pdffilecontent)  
                            # with open('static/files/tempfiletoday.pdf', 'rb') as fh:                      
                                # response = HttpResponse(fh.read(), content_type="application/vnd.ms-excel")
                                # response['Content-Disposition'] = 'inline; filename=' + os.path.basename('static/files/tempfiletoday.pdf')
                                # return response
                            # t['certbytes'] = "<a href={% url 'addstock' %} target='_blank'>View Certificate</a>"
                            t = [t]
                            pd_s = pd.DataFrame.from_dict(t)                    
                            pd_s = pd_s.T
                        print(pd_s)
                        context['output'] = pd_s.to_html(
                            classes='table table-bordered',escape=False)
                    else:
                        t = [s['data']]
                        pd_s = pd.DataFrame.from_dict(t)
                        pd_s = pd_s.T
                        print(pd_s)
                        context['output'] = pd_s.to_html(
                            classes='table table-bordered text-danger')
                else:
                    if response.status_code == 404:  # NOT FOUND
                        pd_s = pd.DataFrame([0], columns=['Not Found'])
                    else:
                        pd_s = pd.DataFrame([0], columns=[response.status_code])
                    context['output'] = pd_s.to_html(
                        classes='table table-bordered text-danger')
                #context['output'] = pd_s.to_html(classes='table table-bordered',index=False)
                context['bcmsg'] = bcmsg
            except:
                context['output'] = {"error": True, "errorCode": "500-1",
                                    "errorText": "error :" + str(traceback.print_exc())}
                # return render(request, "viewstockdepot.html", context)
    else:
        form = SeedCertificateViewForm()
    context['form'] = form
    return render(request, "viewcertificate.html",  context)

def updateCertificate_view(request):
    context = {}
    if not request.session.get('x-access-token', None):
        return render(request, "login.html",  context)    
    # create object of form
    if request.method == 'POST':
        form = SeedCertificateForm(request.POST, request.FILES)
        # check if form data is valid
        if form.is_valid():
            # save the form data to model
            try:
                bcmsg = 'The data updated on MHBCN Blockchain Network'
                print(type(request.POST))
                print(request.FILES)
                api_url = settings.API_URL + "seedChain/"
                api_method = "updateCertificate/"
                api_call_str = api_url + api_method
                print(api_call_str)
                # certfile = request.FILES['certbytes']
                # cert_content_bytes = certfile.file.read()

                s = request.POST
                s = s.dict()
                del s['csrfmiddlewaretoken']  # to remove extra form post form data
                # s['certbytes'] = base64.b64encode(cert_content_bytes).decode('utf-8')
                # s['certHash'] = hashlib.sha256(cert_content_bytes).hexdigest()

                print(s)
                headers = {'content-type': 'application/json'}
                headers['x-access-token'] = request.session.get('x-access-token')
                jsondata = json.dumps(s)

                response = requests.post(
                    api_call_str, data=jsondata, headers=headers, timeout=30000)
                print(str(response))
                if response.status_code == 200:  # SUCCESS
                    s1 = response.json()
                    print(s1)
                    s = json.loads(str(s1))
                    print(s)
                    if str(s['status']) == "Success":
                        print(type(s['data']))
                        t = s['data']
                        t = [t]
                        pd_s = pd.DataFrame.from_dict(t)
                        pd_s = pd_s.T
                        print(pd_s)
                        context['output'] = pd_s.to_html(
                            classes='table table-bordered')
                    else:
                        t = [s['data']]
                        pd_s = pd.DataFrame.from_dict(t)
                        pd_s = pd_s.T
                        print(pd_s)
                        context['output'] = pd_s.to_html(
                            classes='table table-bordered text-danger')
                else:
                    if response.status_code == 404:  # NOT FOUND
                        pd_s = pd.DataFrame([0], columns=['Not Found'])
                    else:
                        pd_s = pd.DataFrame([0], columns=[response.status_code])
                    context['output'] = pd_s.to_html(
                        classes='table table-bordered text-danger')
                #context['output'] = pd_s.to_html(classes='table table-bordered',index=False)
                context['bcmsg'] = bcmsg
            except:
                context['output'] = {"error": True, "errorCode": "500-1",
                                    "errorText": "error :" + str(traceback.print_exc())}
                # return render(request, "viewstockdepot.html", context)        
    else:
        form = SeedCertificateForm()
    context['form'] = form
    return render(request, "updatecertificate.html",  context)

def compareCertificate(request):
    context = {}
    if not request.session.get('x-access-token', None):
        return render(request, "login.html",  context)    
    if request.method == 'POST':
        form = SeedCertificateForm(request.POST, request.FILES)
        # check if form data is valid
        if form.is_valid():
            # save the form data to model
            try:
                bcmsg = 'The data is fetch from MHBCN Blockchain Network'
                print(type(request.POST))
                print(request.FILES)
                api_url = settings.API_URL + "seedChain/"
                api_method = "validateCertificate/"
                api_call_str = api_url + api_method
                print(api_call_str)
                # certfile = request.FILES['certbytes']
                # cert_content_bytes = certfile.file.read()

                s = request.POST
                s = s.dict()
                del s['csrfmiddlewaretoken']  # to remove extra form post form data
                # s['certbytes'] = base64.b64encode(cert_content_bytes).decode('utf-8')
                # s['certHash'] = hashlib.sha256(cert_content_bytes).hexdigest()

                print(s)
                headers = {'content-type': 'application/json'}
                headers['x-access-token'] = request.session.get('x-access-token')
                jsondata = json.dumps(s)

                response = requests.post(
                    api_call_str, data=jsondata, headers=headers, timeout=30000)
                print(str(response))
                if response.status_code == 200:  # SUCCESS
                    s1 = response.json()
                    print(s1)
                    s = json.loads(str(s1))
                    print(s)
                    if str(s['status']) == "Success":
                        print(type(s['data']))
                        t = s['data']
                        t = [t]
                        pd_s = pd.DataFrame.from_dict(t)
                        pd_s = pd_s.T
                        print(pd_s)
                        context['output'] = pd_s.to_html(
                            classes='table table-bordered')
                    else:
                        t = [s['data']]
                        pd_s = pd.DataFrame.from_dict(t)
                        pd_s = pd_s.T
                        print(pd_s)
                        context['output'] = pd_s.to_html(
                            classes='table table-bordered text-danger')
                else:
                    if response.status_code == 404:  # NOT FOUND
                        pd_s = pd.DataFrame([0], columns=['Not Found'])
                    else:
                        pd_s = pd.DataFrame([0], columns=[response.status_code])
                    context['output'] = pd_s.to_html(
                        classes='table table-bordered text-danger')
                #context['output'] = pd_s.to_html(classes='table table-bordered',index=False)
                context['bcmsg'] = bcmsg
            except:
                context['output'] = {"error": True, "errorCode": "500-1",
                                    "errorText": "error :" + str(traceback.print_exc())}
                # return render(request, "viewstockdepot.html", context)        
    else:
        form = SeedCertificateForm()
    context['form'] = form
    return render(request, "comparecertificate.html",  context)

def operateCertificate(request):
    context = {}
    if not request.session.get('x-access-token', None):
        return render(request, "login.html",  context)    
    # create object of form
    if request.method == 'POST':
        form = SeedCertificateJsonForm(request.POST)
        # print(request.POST)
        if form.is_valid():
            # save the form data to model
            try:
                bcmsg = 'Output from MHBCN Blockchain Network'
                # print(type(request.POST))                
                api_url = settings.API_URL + "seedChain/"
                api_method = request.POST['btn'] # "transferBag/"
                api_call_str = api_url + api_method                
                # print(request.POST['jsonInput'])
                jsondata = request.POST['jsonInput'].replace('\r','').replace('\n','').replace('\t','')
                # jsondata = json.loads(request.POST)
                # print(jsondata)
                # del jsondata['csrftoken']

                headers = {'content-type': 'application/json'}  
                headers['x-access-token'] = request.session.get('x-access-token')
                response = requests.post(
                api_call_str, data=jsondata, headers=headers, timeout=30000)
                print(response.json())
                print(type(response.json()))
                if(isinstance(response.json(),dict)):
                    res_dict = json.dumps(response.json(),  indent = 4)
                else:
                    res_dict = json.dumps(json.loads(response.json()),  indent = 4)
                print("Response..--------------------")
                print(res_dict)
                # print(type(res_dict))
                context['output'] = res_dict 
                context['bcmsg'] = bcmsg
            except:
                context['output'] = {"error": True, "errorCode": "500-1",
                                    "errorText": "error :" + str(traceback.print_exc())}                   
    else:
        form = SeedCertificateJsonForm()
    context['form'] = form    
    return render(request, "operateCertificate.html",  context)

def addBag(request):     
    context = {}
    # create object of form
    if request.method == 'POST':
        form = SeedBagForm(request.POST)
        # check if form data is valid
        if form.is_valid():
            # save the form data to model
            try:
                bcmsg = 'The data stored in MHBCN Blockchain Network'
                print(type(request.POST))
                print(request.FILES)
                api_url = settings.API_URL + "seedChain/"
                api_method = "createBag/"
                api_call_str = api_url + api_method
                print(api_call_str)                

                s = request.POST
                s = s.dict()
                del s['csrfmiddlewaretoken']  # to remove extra form post form data
                
                headers = {'content-type': 'application/json'}
                headers['x-access-token'] = request.session.get('x-access-token')
                
                # print(headers[settings.API_KEY])
                jsondata = json.dumps(s)

                response = requests.post(
                    api_call_str, data=jsondata, headers=headers, timeout=30000)
                print(str(response))
                if response.status_code == 200:  # SUCCESS
                    s1 = response.json()
                    print(s1)
                    s = json.loads(str(s1))
                    print(s)
                    if str(s['status']) == "Success":
                        print(type(s['data']))
                        t = s['data']
                        t = [t]
                        pd_s = pd.DataFrame.from_dict(t)
                        pd_s = pd_s.T
                        print(pd_s)
                        context['output'] = pd_s.to_html(
                            classes='table table-bordered')
                    else:
                        t = [s['data']]
                        pd_s = pd.DataFrame.from_dict(t)
                        pd_s = pd_s.T
                        print(pd_s)
                        context['output'] = pd_s.to_html(
                            classes='table table-bordered text-danger')
                else:
                    if response.status_code == 404:  # NOT FOUND
                        pd_s = pd.DataFrame([0], columns=['Not Found'])
                    else:
                        pd_s = pd.DataFrame([0], columns=[response.status_code])
                    context['output'] = pd_s.to_html(
                        classes='table table-bordered text-danger')
                #context['output'] = pd_s.to_html(classes='table table-bordered',index=False)
                context['bcmsg'] = bcmsg
            except:
                context['output'] = {"error": True, "errorCode": "500-1",
                                    "errorText": "error :" + str(traceback.print_exc())}
                # return render(request, "viewstockdepot.html", context)        
    else:
        form = SeedBagForm()
    context['form'] = form    
    return render(request, "addBag.html",  context)

def readBag(request):
    context = {}
    if not request.session.get('x-access-token', None):
        return render(request, "login.html",  context)    
    # create object of form
    if request.method == 'POST':
        form = SeedBagViewForm(request.POST)
        # check if form data is valid
        if form.is_valid():
            # save the form data to model
            try:
                bcmsg = 'The data is fetch from MHBCN Blockchain Network'
                tagNo = request.POST['tagNo']
                lotNumber = request.POST['lotNumber']
                api_url = settings.API_URL + "seedChain/"
                if 'btnViewHistory' in request.POST:
                    api_method = "readBagHistory/"
                else:
                    api_method = "readBag/"
                api_call_str = api_url + api_method
                s = {
                    "tagNo":  tagNo,
                    "lotNumber":  lotNumber
                }
                headers = {'content-type': 'application/json'}
                headers['x-access-token'] = request.session.get('x-access-token')
                jsondata = json.dumps(s)

                response = requests.post(
                    api_call_str, data=jsondata, headers=headers, timeout=30000)
                print(str(response))
                if response.status_code == 200:  # SUCCESS
                    s1 = response.json()
                    print(s1)
                    s = json.loads(str(s1))
                    print(s)
                    if str(s['status']) == "Success":
                        print(type(s['data']))
                        if 'btnViewHistory' in request.POST:
                            t = s['data']  
                            pd_s = pd.DataFrame.from_dict(t)                                             
                        else:
                            t = json.loads(s['data'])                            
                            t = [t]
                            pd_s = pd.DataFrame.from_dict(t)                    
                            pd_s = pd_s.T
                        print(pd_s)
                        context['output'] = pd_s.to_html(
                            classes='table table-bordered',escape=False)
                    else:
                        t = [s['data']]
                        pd_s = pd.DataFrame.from_dict(t)
                        pd_s = pd_s.T
                        print(pd_s)
                        context['output'] = pd_s.to_html(
                            classes='table table-bordered text-danger')
                    context['bcmsg'] = bcmsg
                elif response.status_code == 403:                    
                    pd_s = pd.DataFrame([0], columns=['Authentication Failed'])                    
                    context['output'] = pd_s.to_html(
                        classes='table table-bordered text-danger')
                elif response.status_code == 404:  # NOT FOUND
                    pd_s = pd.DataFrame([0], columns=['Resource Not Found'])
                    context['output'] = pd_s.to_html(classes='table table-bordered text-danger')
                else:
                    pd_s = pd.DataFrame([0], columns=[response.status_code])
                    context['output'] = pd_s.to_html(classes='table table-bordered text-danger')
                #context['output'] = pd_s.to_html(classes='table table-bordered',index=False)
                
            except:
                context['output'] = {"error": True, "errorCode": "500-1",
                                    "errorText": "error :" + str(traceback.print_exc())}
                # return render(request, "viewstockdepot.html", context)
    else:
        form = SeedBagViewForm()
    context['form'] = form
    return render(request, "viewBag.html",  context)

def updateBag(request):
    context = {}
    if not request.session.get('x-access-token', None):
        return render(request, "login.html",  context)    
    # create object of form
    if request.method == 'POST':
        form = SeedBagForm(request.POST)
        # check if form data is valid
        if form.is_valid():
            # save the form data to model
            try:
                bcmsg = 'The data updated in MHBCN Blockchain Network'
                print(type(request.POST))
                print(request.FILES)
                api_url = settings.API_URL + "seedChain/"
                api_method = "updateBag/"
                api_call_str = api_url + api_method
                print(api_call_str)                

                s = request.POST
                s = s.dict()
                del s['csrfmiddlewaretoken']  # to remove extra form post form data
                print(s)
                headers = {'content-type': 'application/json'}
                headers['x-access-token'] = request.session.get('x-access-token')               
                jsondata = json.dumps(s)

                response = requests.post(
                    api_call_str, data=jsondata, headers=headers, timeout=30000)
                print(str(response))
                if response.status_code == 200:  # SUCCESS
                    s1 = response.json()
                    print(s1)
                    s = json.loads(str(s1))
                    print(s)
                    if str(s['status']) == "Success":
                        print(type(s['data']))
                        t = s['data']
                        t = [t]
                        pd_s = pd.DataFrame.from_dict(t)
                        pd_s = pd_s.T
                        print(pd_s)
                        context['output'] = pd_s.to_html(
                            classes='table table-bordered')
                    else:
                        t = [s['data']]
                        pd_s = pd.DataFrame.from_dict(t)
                        pd_s = pd_s.T
                        print(pd_s)
                        context['output'] = pd_s.to_html(
                            classes='table table-bordered text-danger')
                else:
                    if response.status_code == 404:  # NOT FOUND
                        pd_s = pd.DataFrame([0], columns=['Not Found'])
                    else:
                        pd_s = pd.DataFrame([0], columns=[response.status_code])
                    context['output'] = pd_s.to_html(
                        classes='table table-bordered text-danger')
                #context['output'] = pd_s.to_html(classes='table table-bordered',index=False)
                context['bcmsg'] = bcmsg
            except:
                context['output'] = {"error": True, "errorCode": "500-1",
                                    "errorText": "error :" + str(traceback.print_exc())}
                # return render(request, "viewstockdepot.html", context)        
    else:
        form = SeedBagForm()
    context['form'] = form    
    return render(request, "updateBag.html",  context)

def transferBag(request):
    context = {}
    if not request.session.get('x-access-token', None):
        return render(request, "login.html",  context)    
    # create object of form
    if request.method == 'POST':
        form = SeedBagTransferForm(request.POST)
        # check if form data is valid
        if form.is_valid():
            # save the form data to model
            try:
                bcmsg = 'The data updated in MHBCN Blockchain Network'
                # print(type(request.POST))                
                api_url = settings.API_URL + "seedChain/"
                api_method = "transferBag/"
                api_call_str = api_url + api_method
                # print(api_call_str)                
                # print(request.POST['jsonInput'])
                # jsondata = request.POST['jsonInput'].replace('\r','').replace('\n','').replace('\t','')                
                jsondata = json.loads(json.dumps(request.POST))
                print(jsondata)
                del jsondata['csrfmiddlewaretoken']
                jsondata = json.dumps(jsondata)
                headers = {'content-type': 'application/json'}                 
                headers['x-access-token'] = request.session.get('x-access-token')
                # print(headers[settings.API_KEY])
                print(headers['request-timestamp'])
                response = requests.post(
                api_call_str, data=jsondata, headers=headers, timeout=30000)
                
                # print(str(response))
                if response.status_code == 200:  # SUCCESS
                    # res_dict = json.dumps(json.loads(response.json()),  indent = 4)
                    s = json.loads(response.json())
                    if str(s['status']) == "Success":
                        print(type(s['data']))
                        t = s['data']
                        t = [t]
                        pd_s = pd.DataFrame.from_dict(t)
                        pd_s = pd_s.T
                        print(pd_s)
                        context['output'] = pd_s.to_html(
                            classes='table table-bordered')
                    else:
                        t = [s['data']]
                        pd_s = pd.DataFrame.from_dict(t)
                        pd_s = pd_s.T
                        print(pd_s)
                        context['output'] = pd_s.to_html(
                            classes='table table-bordered text-danger')
                else:
                    if response.status_code == 404:  # NOT FOUND
                        pd_s = pd.DataFrame([0], columns=['Not Found'])
                    else:
                        s = response.json()
                        t = [s['data']]
                        pd_s = pd.DataFrame.from_dict(t)
                        pd_s = pd_s.T
                        print(pd_s)
                        context['output'] = pd_s.to_html(
                            classes='table table-bordered text-danger')
                #context['output'] = pd_s.to_html(classes='table table-bordered',index=False)
                context['bcmsg'] = bcmsg
            except:
                context['output'] = {"error": True, "errorCode": "500-1",
                                    "errorText": "error :" + str(traceback.print_exc())}
                # return render(request, "viewstockdepot.html", context)        
    else:
        form = SeedBagTransferForm()
    context['form'] = form    
    return render(request, "transferBag.html",  context)

def login(request):
    context = {}
    if request.method == 'POST':
        username = request.POST['login_email']
        password = request.POST['login_pwd']
        api_url = settings.API_URL + "user/getToken"
        print(api_url)
        jsondata = json.dumps({
            "assetId":username,
            "password":password
        })
        headers = {'content-type': 'application/json'}
        response = requests.post(
                api_url, data=jsondata, headers=headers, timeout=30000)
        
        response = response.json()
        print(response)
        print(type(response))
        if(response['Status'] == "Error"):
            context['errormsg'] = response['data']['errorMessage']
        else: 
            request.session['x-access-token'] = response['data']['token']
            request.session['user'] =request.POST['login_email']
            context["user"] = request.session.get("user")
            gamejoined,gamenotjoined,vyaparclosedgames = getvyapargames(request)
            df_gamejoined = pd.DataFrame(gamejoined)
            df_gamenotjoined = pd.DataFrame(gamenotjoined)
            df_vyaparclosedgames = pd.DataFrame(vyaparclosedgames)
            
            context["vyaparjoinedgames"] = df_gamejoined.to_html(classes="table table-bordered table_hover table-responsive",escape=False,index=False,header=False)
            context["vyapargames"] = df_gamenotjoined.to_html(classes="table table-bordered table_hover table-responsive",escape=False,index=False,header=False)
            context["vyaparclosedgames"] = df_vyaparclosedgames.to_html(classes="table table-bordered table_hover table-responsive",escape=False,index=False,header=False)
            return render(request, 'admin_dashboard.html', context=context)           
    return render(request, "login.html",  context)

def operateBag(request):
    context = {}   
    if not request.session.get('x-access-token', None):
         return render(request, "login.html",  context)    

    # create object of form
    if request.method == 'POST':
        form = SeedBagJsonForm(request.POST)
        print(request.POST)
        if form.is_valid():
            # save the form data to model
            try:
                bcmsg = 'Output from MHBCN Blockchain Network'
                # print(type(request.POST))                
                api_url = settings.API_URL + "seedChain/"
                api_method = request.POST['btn'] # "transferBag/"
                api_call_str = api_url + api_method                
                print(request.POST['jsonInput'])
                jsondata = request.POST['jsonInput'].replace('\r','').replace('\n','').replace('\t','')
                # jsondata = json.loads(request.POST)
                # print(jsondata)
                # del jsondata['csrftoken']

                headers = {'content-type': 'application/json'}                   
                headers['x-access-token'] = request.session.get('x-access-token')
                response = requests.post(
                api_call_str, data=jsondata, headers=headers, timeout=30000)                
                if(isinstance(response.json(),dict)):
                    res_dict = json.dumps(response.json(),  indent = 4)
                else:
                    res_dict = json.dumps(json.loads(response.json()),  indent = 4)
                context['output'] = res_dict 
                context['bcmsg'] = bcmsg
            except:
                context['output'] = {"error": True, "errorCode": "500-1",
                                    "errorText": "error :" + str(traceback.print_exc())}                   
    else:
        form = SeedBagJsonForm()
    context['form'] = form    
    return render(request, "operateBag.html",  context)
# def generate_PDF(request):
#     file = open('static/files/tempfiletoday.pdf', "w+b")
#     file.seek(0)
#     pdf = file.read()
#     file.close()
#     # return HttpResponse(pdf, 'application/pdf')
#     FileResponse(buffer, as_attachment=True, filename='hello.pdf')

def casedetails(request):
    context = {}   
    if not request.session.get('x-access-token', None):
         return render(request, "login.html",  context)    

    # create object of form
    if request.method == 'POST':
        form = CourtCaseJsonForm(request.POST)
        print(request.POST)
        if form.is_valid():
            # save the form data to model
            try:
                bcmsg = 'Output from MHBCN Blockchain Network'
                # print(type(request.POST))                
                api_url = settings.API_URL + "eCourts/"
                api_method = request.POST['btn'] # "transferBag/"
                api_call_str = api_url + api_method                
                print(request.POST['jsonInput'])
                jsondata = request.POST['jsonInput'].replace('\r','').replace('\n','').replace('\t','')
                # jsondata = json.loads(request.POST)
                # print(jsondata)
                # del jsondata['csrftoken']

                headers = {'content-type': 'application/json'}                   
                headers['x-access-token'] = request.session.get('x-access-token')
                response = requests.post(
                api_call_str, data=jsondata, headers=headers, timeout=30000)                
                if(isinstance(response.json(),dict)):
                    res_dict = json.dumps(response.json(),  indent = 4)
                else:
                    res_dict = json.dumps(json.loads(response.json()),  indent = 4)
                context['output'] = res_dict 
                context['bcmsg'] = bcmsg
            except:
                context['output'] = {"error": True, "errorCode": "500-1",
                                    "errorText": "error :" + str(traceback.print_exc())}                   
    else:
        form = CourtCaseJsonForm()
    context['form'] = form    
    return render(request, "caseDetails.html",  context)

def user_login(request):
    # if this is a POST request we need to process the form data
    if request.method == 'POST':
        # create a form instance and populate it with data from the request:
        username = request.POST['login_email']
        password = request.POST['login_pwd']
        user = authenticate(request, username=username, password=password)
        print("Checking password")
        if user is not None:
            print("Found correct user as " + str(user))
            login(request, user)
            return render(request, 'admin_dashboard.html', context={'user': user})
        else:
            print("Found incorrect user, redirecting to login page.")
            return render(request, 'login.html', context={'incorrect_credential': True})

    # if a GET (or any other method) we'll create a blank form
    else:
        #form = LoginForm()

        return render(request, 'login.html', )


def logout(request):
    # del request.session['x-access-token']
    x = request.session.pop('x-access-token')
    auth.logout(request)
    return render(request, 'login.html')


# @login_required



@login_required
def transfer_report(request):
    header_list = []
    all_transfer_list = []
    cursor = connection.cursor()
    cursor.execute("With all_joining1 AS (SELECT t1.employee_id, cast(t1.emp_name as Text), t1.to_location, t1.joining_date, row_number() OVER (PARTITION BY t1.employee_id ORDER BY t1.employee_id, t1.joining_date)::Text AS row_no  FROM (SELECT t.employee_id, ee.name AS emp_name,fl.district_name AS from_location,tl.district_name AS to_location, t.joining_order_date AS joining_date FROM transfer t LEFT JOIN districts fl ON t.from_location_district_id::text = fl.district_code::text  LEFT JOIN districts tl ON t.to_location_district_id::text = tl.district_code::text LEFT JOIN employee ee ON t.employee_id = ee.employee_code UNION  SELECT employee.employee_code, employee.name AS emp_name, 'Initial Posting'::character varying AS from_location, employee.\"place_of_Posting\" AS to_location,employee.joining_date FROM employee) t1) select  cur_tab.employee_id,  cur_tab.emp_name, cur_tab.row_no ,    concat(	cur_tab.to_location, ' (', CASE WHEN (cur_tab.row_no, cur_tab.employee_id)  in (select max(tran.row_no),tran.employee_id from all_joining1 as tran group by tran.employee_id ) THEN get_date_diff(cur_tab.joining_date, CURRENT_DATE) ELSE get_date_diff(cur_tab.joining_date, (select tran.joining_date from all_joining1 as tran where tran.employee_id = cur_tab.employee_id and tran.row_no::int =cur_tab.row_no::int+1  )) END , ')') AS transfer_duration  from all_joining1 as cur_tab order by employee_id, row_no ")
    all_results = cursor.fetchall()
    # print(all_results)
    max_transfer_count = 0
    all_result_dict = {}
    for result in all_results:
        key_val = result[0]
        if key_val not in all_result_dict:
            all_result_dict[key_val] = [result[1]]

        all_result_dict[key_val].append(result[3])
        # print(key_val)

    for key in all_result_dict:
        val = all_result_dict[key]
        length_of_transfers = len(val)-1
        if length_of_transfers > max_transfer_count:
            max_transfer_count = length_of_transfers

    #print("Max transfer is " + str(max_transfer_count))

    for key in all_result_dict:

        temp_list = []
        temp_list.append(key)
        val_list = all_result_dict[key]
        for value in val_list:
            temp_list.append(value)

        diff_len = (max_transfer_count+2) - len(temp_list)

        while diff_len > 0:
            temp_list.append("  ")
            diff_len -= 1

        all_transfer_list.append(temp_list)

    header_list.append('Employee ID')
    header_list.append('Employee Name')
    header_list.append('Initial Joining')

    for i in range(1, max_transfer_count):
        header_list.append('Transfer ' + str(i))

    return render(request, 'transfer_report.html', context={'header_list': header_list, 'all_result': all_transfer_list})


# Create your views here.
# Only logged in superuser can see this view
# LoginRequiredMixin,UserPassesTestMixin,
class EmployeeCreateView(CreateView):
    model = Employee
    template_name = "create.html"
    fields = ['eid', 'emp_id', 'name', 'birth_date',
              'joining_date', 'retirement_date', 'designation', 'post']
    login_url = 'login'  # if not authenticated redirect to login page

    # only superuser is allowed to see this view.
    def test_func(self):
        return self.request.user.is_superuser

    # url to redirect after successfully creation
    def get_success_url(self):
        # Displaying message of successful creation of new employee
        #pu.alert(text='New Employee Created Successfully',title='Create',button='OK')
        return reverse_lazy('employee:employees-list')
