﻿#!/usr/local/bin/env ruby
# -*- coding: utf-8-with-signature -*-
require 'rubygems'
require 'em-websocket'

# チャット用モジュール ユーザー管理を追加
#test
module ChatModule
  # ログイン要求コマンド
  CMD_LOGIN = "[CreateLoginUserCmd]"
  CMD_LOGOUT = "[LogoutUserCmd]"
  CMD_RETURN_LOGIN_OK = "[CreateLoginUserCmd_OK]"
  CMD_RETURN_LOGIN_NG = "[CreateLoginUserCmd_NG]"
  
  # ユーザー管理
  @@connected_clients = Hash.new

  # 受信したメッセージがログイン要求かどうか
  def loginMessage?(msg)
    msgArray = msg.strip.split(":")
    1 < msgArray.size && msgArray[0].include?(CMD_LOGIN)
  end

  # 接続ユーザー全員にメッセージを送る
  def logoutMessage?(msg)
    puts "in logoutMessage function #{msg}"
    pos = msg.index(":")
    msg[pos] = " "
    msg.include?(CMD_LOGOUT)
  end

  # 接続ユーザー全員にメッセージを送る
  def sendBroadcast(msg)
    return if msg.empty?
    @@connected_clients.each_value { |c| c.send(msg) }
    puts msg
  end

  # ログイン処理
  def login(msg)
    msgArray = msg.strip.split(":")
    name = msgArray[1][0...(msgArray[1].size)]
    if @@connected_clients.has_key?(name) == false
      @loginName = name
      @@connected_clients[@loginName] = self
      send(CMD_RETURN_LOGIN_OK)
      puts "Login name is #{@loginName}"
    else
      send(CMD_RETURN_LOGIN_NG)
    end
  end

  #ログアウト処理
  def logout()
    if @loginName && @loginName.empty? == false
      msg = "[#{@loginName}] is logout."
      puts msg
      @@connected_clients.delete(@loginName)
      @@connected_clients.each_value { |c| c.send(msg) }
    end
    puts "WebSocket closed"
  end
end

EM::WebSocket.start(:host => "0.0.0.0", :port => 8080) { |ws|
  ws.extend(ChatModule)
  
  ws.onopen{
    ws.send("Welcome! Please login!")
  }
  
  ws.onmessage { |msg|
    return if msg.strip.size < 1
    
    if ws.loginMessage?(msg)
      ws.login(msg)
    elsif ws.logoutMessage?(msg)
      ws.logout
    else
      ws.sendBroadcast(msg)
    end
  }
  
  ws.onclose{
    ws.logout
  }
  
  ws.onerror{ |e|
    ws.logout
    puts "Error: #{e.message}"
  }
}
