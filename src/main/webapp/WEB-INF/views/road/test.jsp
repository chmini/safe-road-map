<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	
	<link href="/resources/css/main.css" rel="stylesheet" type="text/css">
	<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
	<link href="https://fonts.googleapis.com/css?family=East+Sea+Dokdo&display=swap" rel="stylesheet">	
	
	<title>Insert title here</title>
	
	<meta name="viewport" content="width=device-width, initial-scale=1">
	
	<script src="https://api2.sktelecom.com/tmap/js?version=1&format=javascript&appKey=e5e6c714-9b68-48fe-9ff8-46d3dcc0e411"></script>
	<script src="https://apis.openapi.sk.com/tmap/jsv2?version=1&format=javascript&appkey=e5e6c714-9b68-48fe-9ff8-46d3dcc0e411"></script>
	<script src="https://kit.fontawesome.com/70b6710882.js" crossorigin="anonymous"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
	<script type="text/javascript" src="/resources/js/jquery-ui.js"></script>
	<script type="text/javascript">
		var map, marker, markerLayer;
		var Origin, Dest;
		
		function initTmap(){
			
			//create map
			map = new Tmap.Map({div:'map_div', // map_div
				width:'100%',  // width
				height:'100vh' // height
			});
			
			map.setCenter(new Tmap.LonLat("126.83679367832319", "37.55452233461458").transform("EPSG:4326", "EPSG:3857"), 15);
			
			markerLayer = new Tmap.Layer.Markers();// create markerLayer
			map.addLayer(markerLayer); // add markerLayer
			
			markerRoadLayer = new Tmap.Layer.Markers();
			map.addLayer(markerRoadLayer);
		}
		
		function searchApi(value, num, classL) {
			
			// default parameter
			classL = (typeof classL !== 'undefined') ? classL : null;
			
			// search API
			$.ajax({
				method:"GET",
				url:"https://apis.openapi.sk.com/tmap/pois?version=1&format=xml&callback=result", // Api url
				async:false,
				data:{
					"searchKeyword" : value, // search Keyword
					"resCoordType" : "EPSG3857", // responce coord
					"reqCoordType" : "WGS84GEO", // request coord
					"appKey" : "e5e6c714-9b68-48fe-9ff8-46d3dcc0e411", // Appkey
					"count" : 10
				},
				// success data load
				success:function(response){
					prtcl = response;
					
					if(markerLayer != null) {
						markerLayer.clearMarkers();
					}
					
					var prtclString = new XMLSerializer().serializeToString(prtcl);//xml to String
					
					xmlDoc = $.parseXML( prtclString ),
					$xml = $( xmlDoc ),
					$intRate = $xml.find("poi");
					
					var innerHtml = "";
					var icon, size, offset;
					
					$intRate.each(function(index, element) {
						
					   	var name = element.getElementsByTagName("name")[0].childNodes[0].nodeValue;
					   	var id = element.getElementsByTagName("id")[0].childNodes[0].nodeValue;
									 
					   	innerHtml+="<div><img src='http://tmapapis.sktelecom.com/upload/tmap/marker/pin_b_m_"+index+".png' style='vertical-align:middle'/><span>"+name+"</span></div>";
					   	
						var lon = element.getElementsByTagName("noorLon")[0].childNodes[0].nodeValue;
						var lat = element.getElementsByTagName("noorLat")[0].childNodes[0].nodeValue;
						
						var lonlat = new Tmap.LonLat(lon, lat); //.transform("EPSG:3857", "EPSG:4326"); // coord
						
						size = new Tmap.Size(24, 38); // icon size
						offset = new Tmap.Pixel(-(size.w / 2), -(size.h)); // icon offset
						icon = new Tmap.Icon('http://tmapapis.sktelecom.com/upload/tmap/marker/pin_b_m_'+index+'.png',size, offset);
						
						marker = new Tmap.Marker(lonlat, icon); // create marker
						markerLayer.addMarker(marker); // add marker
						
						// first location
						if(index == 0)
							tmp = marker;
					});
					
					// classfication Tab1 and Tab2
					
					if(num == 1)
						$(".AfterSearch").html(innerHtml);
					else if(num == 2){
						// classfication Origin and Dest	
						if(classL.contains('Origin') && classL !== null)
							icon = new Tmap.Icon('http://tmapapis.sktelecom.com/upload/tmap/marker/pin_r_m_s.png',size, offset);
						if(classL.contains('Dest') && classL !== null)
							icon = new Tmap.Icon('http://tmapapis.sktelecom.com/upload/tmap/marker/pin_r_m_e.png',size, offset);
						
						//$(".Result").html(innerHtml);
						
						marker = new Tmap.Marker(tmp.lonlat, icon);
						markerRoadLayer.addMarker(marker);
						
						marker.icon.imageDiv.className += 'Drag';
						$(".Drag").draggable();
						
						marker.events.register("mousedown", marker, onDown); // mousedown
						marker.events.register("mouseup", marker, onUp); // mouseup
					}					
				},
				// request fail
				error:function(request,status,error) {
					console.log("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
				}
			});
			
			return new Tmap.LonLat(tmp.lonlat.lon, tmp.lonlat.lat).transform("EPSG:3857","EPSG:4326");
		}
		
		function shortestPathApi(Origin, Dest, passList) {
			
			//count = count + 1;
			
			// default parameter passList
			passList = typeof passList !== 'undefined' ? passList : null;
			
			if(markerLayer != null) {
				markerLayer.clearMarkers();
			}
			
			// findRoad api
			var headers = {}; 
			headers["appKey"]="e5e6c714-9b68-48fe-9ff8-46d3dcc0e411"; // Api Key
			
			var prtclString, tDistance, tTime;
			
			$.ajax({
				method:"POST",
				headers : headers,
				url: "https://api2.sktelecom.com/tmap/routes/pedestrian?version=1&format=xml", // pedestrian route guide url
				async:false,
				data:{
					// Start LonLat
					startX : Origin.lon,
					startY : Origin.lat,
					// End LonLat
					endX : Dest.lon,
					endY : Dest.lat,
					// passList LonLat
					passList : passList,
					// Coordinate System
					reqCoordType : "WGS84GEO",
					resCoordType : "EPSG3857",
					// angle
					angle : "172",
					// startName
					startName : "출발지",
					// endName
					endName : "도착지",
					// shortestPath
					searchOption: 10
				},
				// data load success
				success:function(response){
					prtcl = response;					
					
					// print result
					prtclString = new XMLSerializer().serializeToString(prtcl); // xml to String
					
				    xmlDoc = $.parseXML(prtclString),
				    $xml = $( xmlDoc ),
			    	$intRate = $xml.find("Document");
					
					/* console.log($intRate[0]);
					
				    Point = $intRate[0].getElementsByTagName("Point");
				    console.log(Point);
					
					for(var i=0; i<Point.length; i++){
						console.log(Point[i].parentElement.getElementsByTagName("description")[0].textContent);
					} */
			    	
			    	tDistance = $intRate[0].getElementsByTagName("tmap:totalDistance")[0].childNodes[0].nodeValue;
			    	if(tDistance >= 1000)
			    		tDistance = (tDistance/1000).toFixed(1);
			    	
			    	tTime = ($intRate[0].getElementsByTagName("tmap:totalTime")[0].childNodes[0].nodeValue/60).toFixed(0);
					
					prtcl = new Tmap.Format.KML({extractStyles:true, extractAttributes:true}).read(prtcl); // read data(prtcl) and return vectorLayer(feature)
					routeLayer = new Tmap.Layer.Vector("route"); // create vectorLayer
					
					// to read/write standard data format(KML) class
					// to occur event just before add vectorLayer(feature)
					routeLayer.events.register("beforefeatureadded", routeLayer, onBeforeFeatureAdded);
					
					function onBeforeFeatureAdded(e) {
			        	var style = {};
			        	
			        	switch (e.feature.attributes.styleUrl) {
			        	case "#pointStyle":
				        	style.externalGraphic = "http://topopen.tmap.co.kr/imgs/point.png";
				        	style.graphicHeight = 16;
				        	style.graphicOpacity = 1;
				        	style.graphicWidth = 16;
			        	break;
			        	default:
			        		style.strokeColor = "#3396ff"; // apply hexnum color to stroke			        		
				        	style.strokeOpacity = "1"; // stroke opacity
				        	style.strokeWidth = "7"; // stroke width
			        	}; 
			        	
			        	/* if(count == 1)
			        		style.strokeColor = "#009933"; // apply hexnum color to stroke
			        	else
			        		style.strokeColor = "#ff0000"; // apply hexnum color to stroke */
				        	
			        	e.feature.style = style;
			        }
					
					routeLayer.addFeatures(prtcl); // add feature to routeLayer
					map.addLayer(routeLayer); // add routeLayer on map
				}, 
				// if load fail to check error message in console
				error:function(request,status,error){
					console.log("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
				}
			});
			
			//$('.Result').text(tDistance);
			var arr = {'Distance':tDistance, 'Time':tTime, 'prtcl':prtcl, 'prtclString': prtclString};
			
			return arr;
			
			/* routeLayerArr[routeCount] = routeLayer;
			routeCount = routeCount + 1; */
			
			/* var arr = {'prtcl':prtcl, 'prtclString':prtclString, 'tDistance':tDistance, 'tTime':tTime, 'call':count};
			
			return arr; */
		}
		
		var onDown = function () {
			 map.ctrl_nav.dragPan.deactivate();
		}
		
		var onUp = function () {
			 map.ctrl_nav.dragPan.activate();
		}
		
		function openNav() {
			document.getElementById("sideNav").style.display = "block";
		}

		function closeNav() {
			document.getElementById("sideNav").style.display = "none";			
		}
		
		window.onload = function(){
			
			// map
			initTmap();
			
			// mapView marginLeft
			var mapView = document.getElementById('mapView');
			mapView.style.marginLeft = "385px";
			
			// changeBox
			var SearchBox = document.getElementsByClassName('SearchBox')[0];
			var ctrlSearchBox = document.getElementById('ctrlSearchBox');
			
			ctrlSearchBox.onclick = function () {
				SearchBox.classList.toggle('ACTIVE');
				if(SearchBox.classList.contains('ACTIVE')){
					this.children[0].className = 'fas fa-caret-left';
					mapView.style.marginLeft = "385px";
					document.getElementsByClassName('Little_Header')[0].style.display = "none";
				}else{
					this.children[0].className = 'fas fa-caret-right';
					mapView.style.marginLeft = 0;
					document.getElementsByClassName('Little_Header')[0].style.display = "block";
				}	
			}					
			
			// class Btn to Tab Active
			var classBtn = document.getElementsByClassName('Btn');
			var classTab = document.getElementsByClassName('Tab');
			
			for(var i=0; i<classBtn.length; i++){
				
				// click
				classBtn[i].onclick = function () {
					for(var i=0; i<classBtn.length; i++){
						classBtn[i].classList.remove('ACTIVE');
						classTab[i].classList.remove('ACTIVE');
					}
					classTab[this.classList[0]-1].className += ' ACTIVE';
					if(this.classList[0] == 2){
						document.getElementsByClassName('Line Origin')[0].focus();	
					}
					this.className += ' ACTIVE';
				};
			}
			
			// Tab1 
			// BeforeSearch - button Active
			var classNearBy = document.getElementsByClassName('NearBy');
			
			for(var i=0; i<classNearBy.length; i++){
				
				// click
				classNearBy[i].onclick = function () {					
					for(var i=0; i<classNearBy.length; i++){
						if(this.classList.contains('ACTIVE') == false)
							classNearBy[i].classList.remove('ACTIVE');
					}					
					this.classList.toggle('ACTIVE');
				}
			}
			
			// AfterSearch - change display
			var SearchLine = document.getElementsByClassName('SearchLine');
			var SearchBtn = document.getElementsByClassName('SearchBtn');
			
			for(var i=0; i<SearchLine.length; i++){
				SearchLine[i].onkeyup = function(event) {
					if(event.keyCode == 13){
						searchApi(this.value, 1);
						document.getElementsByClassName('BeforeSearch')[0].style.display = 'none';
					}
				}	
			}
			
			for(var i=0; i<SearchBtn.length; i++){
				SearchBtn[i].onclick = function () {
					searchApi(this.parentNode.previousElementSibling.children[0].value, 1);
					document.getElementsByClassName('BeforeSearch')[0].style.display = 'none';
				}
			}
			
			// Tab2 - Origin and Dest focus event
			var Line = document.getElementsByClassName('Line');
			var Origin, Dest;
			
			/* if(Line[0].value == "")
				console.log('hello'); */
			
			for(var i=0; i<Line.length; i++){
				
				// focus
				Line[i].onfocus = function () {
					for(var i=0; i<Line.length; i++){
						Line[i].closest('div').classList.remove('ACTIVE');
					}
					this.closest('div').className += ' ACTIVE';
				}
				
				// blur
				Line[i].onblur = function () {
					Line[0].closest('div').style.removeProperty('border-bottom');
					this.closest('div').classList.remove('ACTIVE');
				}
				
				// enter event
				Line[i].onkeyup = function(event) {
					if(event.keyCode == 13){
						if(this.classList.contains('Origin')){
							document.getElementsByClassName('Line Dest')[0].focus();
							Origin = searchApi(this.value, 2, this.classList);
						}
						if(this.classList.contains('Dest')){
							Dest = searchApi(this.value, 2, this.classList);
						}
					}
				}
			}
			
			// Tab2 - WayBtn event
			var Foot = document.getElementsByClassName('Foot')[0];
			var Path = document.getElementsByClassName('Path');
			var Detail;
			
			var innerHtml = "";
			
			Foot.onclick = function () {
				result = shortestPathApi(Origin, Dest);
				this.className += ' ACTIVE'; 
				
				$('.Shortest .Distance').text(result.Distance+"km");
				$('.Shortest .Time').text(result.Time+"분");
				prtclString = result.prtclString;
				
				xmlDoc = $.parseXML(prtclString),
			    $xml = $( xmlDoc ),
		    	$intRate = $xml.find("Document");
				
			    Point = $intRate[0].getElementsByTagName("Point");
				
				for(var i=0; i<Point.length; i++){
					description = Point[i].parentElement.getElementsByTagName("description")[0].textContent;
					if(description.includes("좌회전")){
						icon = "<img src='/resources/img/turn-left.svg' width=24 height=24>";
						innerHtml += "<li>"+icon+""+description+"</li>";
					}else if(description.includes("우회전")){
						icon = "<img src='/resources/img/turn-left.svg' width=24 height=24 style='transform: scaleX(-1);'>";
						innerHtml += "<li>"+icon+""+description+"</li>";
					}else if(description.includes("횡단보도")){
						icon = "<img src='/resources/img/pedestrian.svg' width=24 height=24>";
						innerHtml += "<li>"+icon+""+description+"</li>";
					}else{
						icon = "<img src='/resources/img/upload.svg' width=24 height=24>";
						innerHtml += "<li>"+icon+""+description+"</li>";
					}
				}				
				
				Detail = document.getElementsByClassName('Detail')[0];
				Detail.children[0].innerHTML = innerHtml;
				Detail.style.paddingBottom = "20px";
				
				for(var i=0; i<Path.length; i++){
					Path[i].style.display = "block";
				}
			}
			
			var Content = document.getElementsByClassName('Content');
			
			for(var i=0; i<Content.length; i++){
				Content[i].onclick = function () {
					this.nextElementSibling.classList.toggle('ACTIVE');
					if(this.nextElementSibling.classList.contains('ACTIVE')){
						for(var i=0; i<this.childNodes.length; i++){
							if(this.childNodes[i].classList != undefined && this.childNodes[i].classList.contains('DetailBtn'))
								this.childNodes[i].children[0].className = 'fas fa-sort-up';
						}						
					}else{
						for(var i=0; i<this.childNodes.length; i++){
							if(this.childNodes[i].classList != undefined && this.childNodes[i].classList.contains('DetailBtn'))
								this.childNodes[i].children[0].className = 'fas fa-sort-down';
						}
					}
				}
			}			
			
			// Tab2 - result event
			// hover
			var Path = document.getElementsByClassName('Path');
			
			for(var i=0; i<Path.length; i++){
				Path[i].onmouseover = function () {
					this.children[0].children[0].style.color = "#3396ff";
					this.children[0].children[0].style.fontWeight = "bold";
				}
				
				Path[i].onmouseout = function () {
					this.children[0].children[0].style.color = "#000";
					this.children[0].children[0].style.fontWeight = "";
				}
			}
			
			// resize
			var Body = document.getElementsByClassName('Body')[0];
			Body.style.height = (window.innerHeight-198)+"px";
			
			window.onresize = function() {
				Body.style.height = (window.innerHeight-198)+"px";
			}			
		}
	</script>
</head>
<body>
	<div id="sideNav" class="SideNav">
		<div class="LogoImg">				
			<h1>대동여지도</h1>
		</div>
		<button onclick="closeNav()"><img src="/resources/img/close_icon.png" width="24" height="24"></button>
		<div class="SideNavMenu">
			<ul>
		    	<li><i class="far fa-lightbulb"></i><a href="#">공지사항</a></li>
		    	<li><i class="fas fa-bullhorn"></i><a href="#">고객센터</a></li>			    	
		    </ul>
		</div>
	</div>
	
	<div id="searchBox" class="SearchBox ACTIVE">
		<div class="Header">
			<div class="Title">
				<div class="Menu Thick" onclick="openNav()">&#9776;</div>
				<div class="Logo">대동여지도</div>
			</div>
			<div class="SearchBar">
				<div><input type="text" class="SearchLine" name="address" placeholder="주소 검색"></div>
     			<div><button class="SearchBtn"><i class="fas fa-search"></i></button></div>
			</div>
			<div class="Menu">
				<table>
					<tr>
						<td><button class="1 Btn">검색</button></td>
						<td><button class="2 Btn ACTIVE">길찾기</button></td>						
					</tr>
				</table>
			</div>
		</div>
		<div class="Body">
			<div class="1 Tab">
				<div class="BeforeSearch">
					<div class="Title">
						주변탐색
					</div>
					<div class="Body">
						<table>
							<tr>
								<td><button class="NearBy Restaurants"><img src="/resources/img/security-camera.svg" ></button></td>
								<td><button class="NearBy Cafe"><img src="/resources/img/streetLamp.svg"></button></td>
								<td><button class="NearBy NearBy Store"><img src="/resources/img/emergencyBell.svg"></button></td>
								<td><button class="NearBy Subway"><img src="/resources/img/policeStation.svg"></button></td>
								<td><button class="NearBy Bus"><img src="/resources/img/fireStation.svg"></button></td>
							</tr>
							<tr>
								<td>CCTV</td>
								<td>보안등</td>								
								<td>비상벨</td>
								<td>경찰서</td>
								<td>소방서</td>
							</tr>
						</table>
					</div>
				</div>
				<div class="AfterSearch">
					
				</div>
			</div>
			<div class="2 Tab ACTIVE">
				<div class="WaySearchBox">
					<div class="WayPointBox Origin">
						<div class="WayPointWindow Origin ACTIVE">
							<input type="text" class="Line Origin" placeholder="출발지를 입력하세요">
						</div>
					</div>
					<div class="WayPointBox Dest">
						<div class="WayPointWindow Dest">
							<input type="text" class="Line Dest" placeholder="도착지를 입력하세요">
						</div>
					</div>
					<div class="Way">
					    <div class="WayBox">
					        <button class="WayBtn Car"><i class="fas fa-car"></i></button>
					        <button class="WayBtn Bus"><i class="fas fa-bus"></i></button>
					        <button class="WayBtn Foot"><i class="fas fa-walking"></i></button>
					        <button class="WayBtn Bike"><i class="fas fa-bicycle"></i></button>
					    </div>
					</div>
				</div>
				<div class="Result">
					<div class="Path Shortest">
						<div class="Content">
							<div class="Mode">최단거리</div><span class="DetailBtn"><i class="fas fa-sort-down"></i></span>
							<div class="TD">
								<div class="Time">17분</div>
								<div class="Distance">1.2km</div>
							</div>							
						</div>
						<div class="Detail">
							<ul>
							</ul>
						</div>
					</div>
					<div class="Path Safe">
						<div class="Content">
							<div class="Mode">안전한길</div><span class="DetailBtn"><i class="fas fa-sort-down"></i></span>
							<div class="TD">
								<div class="Time">22분</div>
								<div class="Distance">1.7km</div>
							</div>
						</div>
						<div class="Detail">
							<ul>
							</ul>
						</div>
					</div>
				</div>
			</div>			
		</div>
		<div class="Footer">
			
		</div>
	</div>
	
	<div id="mapView">		
		<div class="SideBtn">
			<div class="BtnSearchBox">
				<button id="ctrlSearchBox"><i class="fas fa-caret-left"></i></button>
			</div>
		</div>
		<div class="Little_Header">
			<div class="Little_Title">
				<div class="Little_Menu Thick" onclick="openNav()">&#9776;</div>
				<div class="Little_Logo">대동여지도</div>
			</div>
			<div class="Little_SearchBar">
				<div><input type="text" class="Little SearchLine" name="address" placeholder="주소 검색"></div>
      			<div><button type="submit" class="Little SearchBtn"><i class="fas fa-search"></i></button></div>
			</div>
		</div>
		<div id="map_div"></div>
	</div>
	
</body>
</html>

