﻿<%--
    Myrtille: A native HTML4/5 Remote Desktop Protocol client.

    Copyright(c) 2014-2018 Cedric Coste

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

	    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
--%>

<%@ Page Language="C#" Inherits="Myrtille.Web.Default" Codebehind="Default.aspx.cs" AutoEventWireup="true" Culture="auto" UICulture="auto" %>
<%@ OutputCache Location="None" %>
<%@ Import Namespace="System.Globalization" %>
<%@ Import Namespace="Myrtille.Web" %>
<%@ Import Namespace="Myrtille.Services.Contracts" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
	
    <head>

        <!-- force IE out of compatibility mode -->
        <meta http-equiv="X-UA-Compatible" content="IE=edge, chrome=1"/>

        <!-- mobile devices -->
        <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1.0"/>
        
        <title>Myrtille</title>
        
        <link rel="icon" type="image/png" href="img/myrtille.png"/>
        <link rel="stylesheet" type="text/css" href="css/Default.css"/>
        <link rel="stylesheet" type="text/css" href="css/xterm.css"/>

        <script language="javascript" type="text/javascript" src="js/myrtille.js"></script>
        <script language="javascript" type="text/javascript" src="js/config.js"></script>
        <script language="javascript" type="text/javascript" src="js/dialog.js"></script>
        <script language="javascript" type="text/javascript" src="js/display.js"></script>
        <script language="javascript" type="text/javascript" src="js/display/canvas.js"></script>
        <script language="javascript" type="text/javascript" src="js/display/divs.js"></script>
        <script language="javascript" type="text/javascript" src="js/display/terminaldiv.js"></script>
        <script language="javascript" type="text/javascript" src="js/network.js"></script>
        <script language="javascript" type="text/javascript" src="js/network/buffer.js"></script>
        <script language="javascript" type="text/javascript" src="js/network/longpolling.js"></script>
        <script language="javascript" type="text/javascript" src="js/network/websocket.js"></script>
        <script language="javascript" type="text/javascript" src="js/network/xmlhttp.js"></script>
        <script language="javascript" type="text/javascript" src="js/user.js"></script>
        <script language="javascript" type="text/javascript" src="js/user/keyboard.js"></script>
        <script language="javascript" type="text/javascript" src="js/user/mouse.js"></script>
        <script language="javascript" type="text/javascript" src="js/user/touchscreen.js"></script>
        <script language="javascript" type="text/javascript" src="js/xterm/xterm.js"></script>
        <script language="javascript" type="text/javascript" src="js/xterm/addons/fit/fit.js"></script>

	</head>
	
    <body onload="startMyrtille(
        <%=(RemoteSession != null && (RemoteSession.State == RemoteSessionState.Connecting || RemoteSession.State == RemoteSessionState.Connected)).ToString(CultureInfo.InvariantCulture).ToLower()%>,
        <%=(RemoteSession != null && RemoteSession.StatMode).ToString(CultureInfo.InvariantCulture).ToLower()%>,
        <%=(RemoteSession != null && RemoteSession.DebugMode).ToString(CultureInfo.InvariantCulture).ToLower()%>,
        <%=(RemoteSession != null && RemoteSession.CompatibilityMode).ToString(CultureInfo.InvariantCulture).ToLower()%>,
        <%=(RemoteSession != null && RemoteSession.ScaleDisplay).ToString(CultureInfo.InvariantCulture).ToLower()%>,
        <%=(RemoteSession != null ? RemoteSession.ClientWidth.ToString() : "null")%>,
        <%=(RemoteSession != null ? RemoteSession.ClientHeight.ToString() : "null")%>,
        '<%=(RemoteSession != null ? RemoteSession.HostType.ToString() : HostTypeEnum.RDP.ToString())%>');">

        <!-- custom UI: all elements below, including the logo, are customizable into Default.css -->

        <form method="post" runat="server" id="mainForm">

            <!-- display resolution -->
            <input type="hidden" runat="server" id="width"/>
            <input type="hidden" runat="server" id="height"/>

            <!-- ********************************************************************************************************************************************************************************** -->
            <!-- *** LOGIN                                                                                                                                                                      *** -->
            <!-- ********************************************************************************************************************************************************************************** -->
            
            <div runat="server" id="login" visible="false">

                <!-- customizable logo -->
                <div runat="server" id="logo"></div>

                <!-- standard mode -->
                <div runat="server" id="hostConnectDiv">

                    <!-- type -->
                    <div class="inputDiv">
                        <label id="hostTypeLabel" for="hostType">Protocol</label>
                        <select runat="server" id="hostType" onchange="onHostTypeChange(this);" title="host type">
                            <option value="0" selected="selected">RDP</option>
                            <option value="0">RDP over VM bus (Hyper-V)</option>
                            <option value="1">SSH</option>
                        </select>
                    </div>

                    <!-- security -->
                    <div class="inputDiv" id="securityProtocolDiv">
                        <label id="securityProtocolLabel" for="securityProtocol">Security</label>
                        <select runat="server" id="securityProtocol" title="NLA = safest, RDP = backward compatibility (if the server doesn't enforce NLA) and interactive logon (leave user and password empty); AUTO for Hyper-V VM or if not sure">
                            <option value="0" selected="selected">AUTO</option>
                            <option value="1">RDP</option>
                            <option value="2">TLS</option>
                            <option value="3">NLA</option>
                            <option value="4">NLA-EXT</option>
                        </select>
                    </div>

                    <!-- server -->
                    <div class="inputDiv">
                        <label id="serverLabel" for="server">Server (:port)</label>
                        <input type="text" runat="server" id="server" title="host name or address (:port, if other than the standard 3389 (rdp), 2179 (rdp over vm bus) or 22 (ssh)). use [] for ipv6. CAUTION! if using a hostname or if you have a connection broker, make sure the DNS is reachable by myrtille (or myrtille has joined the domain)"/>
                    </div>

                    <!-- hyper-v -->
                    <div id="vmDiv" style="visibility:hidden;display:none;">

                        <!-- vm guid -->
                        <div class="inputDiv" id="vmGuidDiv">
                            <label id="vmGuidLabel" for="vmGuid">VM GUID</label>
                            <input type="text" runat="server" id="vmGuid" title="guid of the Hyper-V VM to connect"/>
                        </div>

                        <!-- enhanced mode -->
                        <div class="inputDiv" id="vmEnhancedModeDiv">
                            <label id="vmEnhancedModeLabel" for="vmEnhancedMode">VM Enhanced Mode</label>
                            <input type="checkbox" runat="server" id="vmEnhancedMode" title="faster display and clipboard/printer redirection, if supported by the guest VM"/>
                        </div>

                    </div>

                    <!-- domain -->
                    <div class="inputDiv" id="domainDiv">
                        <label id="domainLabel" for="domain">Domain (optional)</label>
                        <input type="text" runat="server" id="domain" title="user domain (if applicable)"/>
                    </div>

                </div>
                
                <!-- user -->
                <div class="inputDiv">
                    <label id="userLabel" for="user">User</label>
                    <input type="text" runat="server" id="user" title="user name"/>
                </div>

                <!-- password -->
                <div class="inputDiv">
                    <label id="passwordLabel" for="password">Password</label>
                    <input type="password" runat="server" id="password" title="user password"/>
                </div>

                <!-- hashed password (aka password 51) -->
                <input type="hidden" runat="server" id="passwordHash"/>

                <!-- MFA password -->
                <div class="inputDiv" runat="server" id="mfaDiv" visible="false">
                    <a runat="server" id="mfaProvider" href="#" target="_blank" tabindex="-1" title="MFA provider"></a>
                    <input type="text" runat="server" id="mfaPassword" title="MFA password"/>
                </div>

                <!-- program to run -->
                <div class="inputDiv">
                    <label id="programLabel" for="program">Program to run (optional)</label>
                    <input type="text" runat="server" id="program" title="executable path, name and parameters (double quotes must be escaped) (optional)"/>
                </div>

                <!-- connect -->
                <input type="submit" runat="server" id="connect" value="Connect!" onserverclick="ConnectButtonClick" title="open session"/>

                <!-- myrtille version -->
                <div id="version">
                    <a href="http://cedrozor.github.io/myrtille/" target="_blank" title="myrtille">
                        <img src="img/myrtille.png" alt="myrtille" width="15px" height="15px"/>
                    </a>
                    <span>
                        <%=typeof(Default).Assembly.GetName().Version%>
                    </span>
                </div>

                <!-- connect error -->
                <div id="errorDiv">
                    <span runat="server" id="connectError"></span>
                </div>
                
            </div>

            <!-- ********************************************************************************************************************************************************************************** -->
            <!-- *** HOSTS                                                                                                                                                                      *** -->
            <!-- ********************************************************************************************************************************************************************************** -->

            <div runat="server" id="hosts" visible="false">
                
                <div id="hostsControl">

                    <!-- enterprise user info -->
                    <input type="text" runat="server" id="enterpriseUserInfo" title="logged in user" disabled="disabled"/>

                    <!-- new rdp host -->
                    <input type="button" runat="server" id="newRDPHost" value="New RDP Host" onclick="openPopup('editHostPopup', 'EditHost.aspx?hostType=RDP');" title="New RDP Host (standard or over VM bus)"/>

                    <!-- new ssh host -->
                    <input type="button" runat="server" id="newSSHHost" value="New SSH Host" onclick="openPopup('editHostPopup', 'EditHost.aspx?hostType=SSH');" title="New SSH Host"/>
                
                    <!-- logout -->
                    <input type="button" runat="server" id="logout" value="Logout" onserverclick="LogoutButtonClick" title="Logout"/>

                </div>
                
                <!-- hosts list -->
                <asp:Repeater runat="server" id="hostsList" OnItemDataBound="hostsList_ItemDataBound">
                    <ItemTemplate>
                        <div class="hostDiv">
                            <a runat="server" id="hostLink" title="connect">
                                <img src="<%# Eval("HostImage").ToString() %>" alt="host" width="128px" height="128px"/>
                            </a>
                            <br/>
                            <span runat="server" id="hostName"></span>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>

            </div>

            <!-- ********************************************************************************************************************************************************************************** -->
            <!-- *** TOOLBAR                                                                                                                                                                    *** -->
            <!-- ********************************************************************************************************************************************************************************** -->
            
            <div runat="server" id="toolbarToggle" style="visibility:hidden;display:none;">
                <!-- icon from: https://icons8.com/ -->
			    <img src="img/icons8-menu-horizontal-21.png" alt="show/hide toolbar" width="21px" height="21px" onclick="toggleToolbar();"/>
            </div>

            <div runat="server" id="toolbar" style="visibility:hidden;display:none;">

                <!-- server info -->
                <input type="text" runat="server" id="serverInfo" title="connected server" disabled="disabled"/>

                <!-- user info -->
                <input type="text" runat="server" id="userInfo" title="connected user" disabled="disabled"/>

                <!-- stat bar -->
                <input type="button" runat="server" id="stat" value="Show Stat" onclick="toggleStatMode();" title="display network and rendering info" disabled="disabled"/>

                <!-- debug log -->
                <input type="button" runat="server" id="debug" value="Show Debug" onclick="toggleDebugMode();" title="display debug info" disabled="disabled"/>

                <!-- browser mode -->
                <input type="button" runat="server" id="browser" value="HTML4" onclick="toggleCompatibilityMode();" title="rendering mode" disabled="disabled"/>

                <!-- scale display -->
                <input type="button" runat="server" id="scale" value="Scale" onclick="toggleScaleDisplay();" title="dynamically scale the remote session display to the browser size (responsive design)" disabled="disabled"/>

                <!-- virtual keyboard. on devices without a physical keyboard, forces the device virtual keyboard to pop up -->
                <input type="button" runat="server" id="keyboard" value="Keyboard" onclick="openPopup('virtualKeyboardPopup', 'VirtualKeyboard.aspx');" title="send text to the remote session (tip: can be used to send the local clipboard content (text only))" disabled="disabled"/>

                <!-- remote clipboard. display the remote clipboard content and allow to copy it locally (text only) -->
                <input type="button" runat="server" id="clipboard" value="Clipboard" onclick="requestRemoteClipboard();" title="retrieve the remote clipboard content (text only)" disabled="disabled"/>

                <!-- upload/download file(s). only enabled if the connected server is localhost or if a domain is specified (so file(s) can be accessed within the remote session) -->
                <input type="button" runat="server" id="files" value="Files" onclick="openPopup('fileStoragePopup', 'FileStorage.aspx');" title="upload/download files to/from the user documents folder" disabled="disabled"/>

                <!-- send ctrl+alt+del. may be useful to change the user password, for example -->
                <input type="button" runat="server" id="cad" value="Ctrl+Alt+Del" onclick="sendCtrlAltDel();" title="send Ctrl+Alt+Del" disabled="disabled"/>

                <!-- send a right-click on the next touch or left-click action. may be useful on touchpads or iOS devices -->
                <input type="button" runat="server" id="mrc" value="Right-Click OFF" onclick="toggleRightClick(this);" title="if toggled on, send a Right-Click on the next touch or left-click action" disabled="disabled"/>

                <!-- swipe up/down gesture management for touchscreen devices. emulate vertical scroll in applications -->
                <input type="button" runat="server" id="vswipe" value="Swipe up/down ON" onclick="toggleVerticalSwipe(this);" title="if toggled on, allow vertical scroll on swipe (experimental feature, disabled on IE/Edge)" disabled="disabled"/>

                <!-- share session -->
                <input type="button" runat="server" id="share" value="Share" onclick="openPopup('shareSessionPopup', 'ShareSession.aspx');" title="share session" disabled="disabled"/>

                <!-- disconnect -->
                <input type="button" runat="server" id="disconnect" value="Disconnect" onserverclick="DisconnectButtonClick" title="disconnect session" disabled="disabled"/>

            </div>

            <!-- remote session display -->
            <div id="displayDiv"></div>

            <!-- remote session helpers -->
            <div id="cacheDiv"></div>
            <div id="statDiv"></div>
		    <div id="debugDiv"></div>
            <div id="msgDiv"></div>
            <div id="kbhDiv"></div>
            <div id="bgfDiv"></div>

        </form>

        <script type="text/javascript" language="javascript" defer="defer">

            initDisplay();

            // auto-connect / start program from url
            // if the display resolution isn't set, the remote session isn't able to start; redirect with the client resolution
            if (window.location.href.indexOf('&connect=') != -1 && (window.location.href.indexOf('&width=') == -1 || window.location.href.indexOf('&height=') == -1))
            {
                var width = document.getElementById('<%=width.ClientID%>').value;
                var height = document.getElementById('<%=height.ClientID%>').value;

                var redirectUrl = window.location.href;

                if (window.location.href.indexOf('&width=') == -1)
                {
                    redirectUrl += '&width=' + width;
                }

                if (window.location.href.indexOf('&height=') == -1)
                {
                    redirectUrl += '&height=' + height;
                }

                //alert('reloading page with url:' + redirectUrl);

                window.location.href = redirectUrl;
            }

            function initDisplay()
            {
                try
                {
                    var display = new Display();

                    // detect the browser width & height
                    setClientResolution(display);

                    // swipe is disabled on IE/Edge because it emulates mouse events by default (experimental)
                    document.getElementById('<%=vswipe.ClientID%>').disabled = display.isIEBrowser();
                }
                catch (exc)
                {
                    alert('myrtille initDisplay error: ' + exc.message);
                }
            }

            function onHostTypeChange(hostType)
            {
                var securityProtocolDiv = document.getElementById('securityProtocolDiv');
                if (securityProtocolDiv != null)
                {
                    securityProtocolDiv.style.visibility = (hostType.selectedIndex == 0 ? 'visible' : 'hidden');
                    securityProtocolDiv.style.display = (hostType.selectedIndex == 0 ? 'block' : 'none');
                }

                var vmDiv = document.getElementById('vmDiv');
                if (vmDiv != null)
                {
                    vmDiv.style.visibility = (hostType.selectedIndex == 1 ? 'visible' : 'hidden');
                    vmDiv.style.display = (hostType.selectedIndex == 1 ? 'block' : 'none');
                }

                var domainDiv = document.getElementById('domainDiv');
                if (domainDiv != null)
                {
                    domainDiv.style.visibility = (hostType.selectedIndex == 0 ? 'visible' : 'hidden');
                    domainDiv.style.display = (hostType.selectedIndex == 0 ? 'block' : 'none');
                }
            }

            function setClientResolution(display)
            {
                // browser size. default 1024x768
                var width = display.getBrowserWidth() - display.getHorizontalOffset();
                var height = display.getBrowserHeight() - display.getVerticalOffset();

                //alert('client width: ' + width + ', height: ' + height);

                document.getElementById('<%=width.ClientID%>').value = width;
                document.getElementById('<%=height.ClientID%>').value = height;
            }

            function disableControl(controlId)
            {
                var control = document.getElementById(controlId);
                if (control != null)
                {
                    control.disabled = true;
                }
            }

            function disableToolbar()
            {
                disableControl('<%=stat.ClientID%>');
                disableControl('<%=debug.ClientID%>');
                disableControl('<%=browser.ClientID%>');
                disableControl('<%=scale.ClientID%>');
                disableControl('<%=keyboard.ClientID%>');
                disableControl('<%=clipboard.ClientID%>');
                disableControl('<%=files.ClientID%>');
                disableControl('<%=cad.ClientID%>');
                disableControl('<%=mrc.ClientID%>');
                disableControl('<%=share.ClientID%>');
                disableControl('<%=disconnect.ClientID%>');
            }

            function toggleToolbar()
            {
                var toolbar = document.getElementById('<%=toolbar.ClientID%>');

                if (toolbar == null)
                    return;

	            if (toolbar.style.visibility == 'visible')
                {
                    toolbar.style.visibility = 'hidden';
                    toolbar.style.display = 'none';
                }
                else
                {
                    toolbar.style.visibility = 'visible';
                    toolbar.style.display = 'block';
	            }
            }

		</script>

	</body>

</html>