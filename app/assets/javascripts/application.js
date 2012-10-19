// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require_tree .
      var Socket = "MozWebSocket" in window ? MozWebSocket : WebSocket;
      var ws;
      
      function reciveDataSpace(string) {
        var element = document.getElementById("reciveDataSpace");
        var p = document.createElement("p");
        p.appendChild(document.createTextNode(string));
        element.appendChild(p);
      }
      
      function loginState(string) {
        var element = document.getElementById("loginState");
        element.innerHTML = "<p>" + string + "</p>";
      }
 
      function init() {
        Socket = "MozWebSocket" in window ? MozWebSocket : WebSocket;
        ws = new Socket("ws://133.1.134.53:8080/");
        
        ws.onmessage = function(evt) {
          if("[CreateLoginUserCmd_OK]" == evt.data){
            loginState("login");
            changeloginState();
          }
          else if("[CreateLoginUserCmd_NG]" == evt.data){
            loginState("The login name is already used. ");
          }
          else{
            reciveDataSpace("Message: " + evt.data); 
          }
        };
         
        ws.onclose = function() { reciveDataSpace("socket closed"); };
        
        ws.onopen = function() {
          reciveDataSpace("connected...");
        }
      }
      
      function sendMessage(){
        var sendMsg = document.getElementById("message");
        var name = document.getElementById("loginName");
        if(sendMsg.value == "") return;
        if(name.value == "") return;
        ws.send("[" + name.value + "]:" + sendMsg.value);
        sendMsg.value = "";
      }
      
      function sendLogin(){
        loginState("");
        var name = document.getElementById("loginName");
        if(name.value == "") {
          loginState("Name is empty.");
          return;
        }
        ws.send("[CreateLoginUserCmd]:" + name.value);
      }
      
      function changeloginState(){
        var name = document.getElementById("loginName");
        if(name.value == "") return;
        var login = document.getElementById("buttonLogin");
        login.disabled = true;
        var name = document.getElementById("loginName");
        name.disabled = true;
        var sendBtn = document.getElementById("buttonSend");
        sendBtn.disabled = false;
      };

      