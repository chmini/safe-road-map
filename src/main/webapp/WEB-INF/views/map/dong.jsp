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
	
	<script src="https://api2.sktelecom.com/tmap/js?version=1&format=javascript&appKey=2565ae33-8d60-42ce-9fe7-14d4a8940254"></script>
	<script src="https://apis.openapi.sk.com/tmap/jsv2?version=1&format=javascript&appkey=2565ae33-8d60-42ce-9fe7-14d4a8940254"></script>
	<script src="https://kit.fontawesome.com/70b6710882.js" crossorigin="anonymous"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
	<script type="text/javascript" src="/resources/js/jquery-ui.js"></script>
	<script type="text/javascript">
		var map, marker, markerLayer, markercctvLayer;
		var circle, circleFeature, vectorLayer;
		var Origin, Dest;
		
		function initTmap(){
			
			//create map
			map = new Tmap.Map({div:'map_div', // map_div
				width:'100%',  // width
				height:'100vh' // height
			});
			
			map.setCenter(new Tmap.LonLat("126.84868122866818", "37.567322064133464").transform("EPSG:4326", "EPSG:3857"), 16);
			
			markerLayer = new Tmap.Layer.Markers("markerLayer");// create markerLayer
			map.addLayer(markerLayer); // add markerLayer
			
			markerStartLayer = new Tmap.Layer.Markers("markerStartLayer");
			map.addLayer(markerStartLayer);
			
			markerEndLayer = new Tmap.Layer.Markers("markerEndLayer");
			map.addLayer(markerEndLayer);
			
			markercctvLayer = new Tmap.Layer.Markers("markercctvLayer");
			map.addLayer(markercctvLayer);
			
			markerSafeLayer = new Tmap.Layer.Markers("markerSafeLayer");
			map.addLayer(markerSafeLayer);
			
			vectorLayer = new Tmap.Layer.Vector("vectorLayer"); // Create vectorLayer
			map.addLayers([vectorLayer]); // Add vectorLayer to map
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
					"appKey" : "2565ae33-8d60-42ce-9fe7-14d4a8940254", // Appkey
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
						if(classL.contains('Origin') && classL !== null){
							icon = new Tmap.Icon('http://tmapapis.sktelecom.com/upload/tmap/marker/pin_b_m_s.png',size, offset);
							marker = new Tmap.Marker(tmp.lonlat, icon);
							markerStartLayer.addMarker(marker);
						}							
						if(classL.contains('Dest') && classL !== null){
							icon = new Tmap.Icon('http://tmapapis.sktelecom.com/upload/tmap/marker/pin_b_m_e.png',size, offset);
							marker = new Tmap.Marker(tmp.lonlat, icon);
							markerEndLayer.addMarker(marker);
						}
						
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
		
		// For marker style
    	var icon, size, offset;    	
    	
    	// Start, End LonLat and Pixel 
    	var startLon, startLat, endLon, endLat; // startPixel, endPixel;
    	
    	// For draw circle
    	var centerLon, centerLat, radius, distance;
    	var styleCircle = {
				fillColor:"#3396ff",
				fillOpacity: 0,
				strokeColor: "#3396ff",
				strokeWidth: 3,
				strokeDashstyle: "solid",
				pointRadius: 60
			};    	
    	
    	var compRound = new Array(); // To compare cctv and circle round
		var markRound = new Array(); // check for eyes
		
		// Converts from degrees to radians.
		Math.radians = function(degrees) {
		  return degrees * Math.PI / 180;
		};
		 
		// Converts from radians to degrees.
		Math.degrees = function(radians) {
		  return radians * 180 / Math.PI;
		};
		
		// To remove routeLayers
		var routeCount = 0;
		var safeRoute = new Array();
		
		function shortestPathApi(Origin, Dest, count, passList) {
			
			count = count + 1;
			
			// default parameter passList
			passList = typeof passList !== 'undefined' ? passList : null;
			
			/* if(markerLayer != null) {
				markerLayer.clearMarkers();
			} */
			
			// findRoad api
			var headers = {}; 
			headers["appKey"]="2565ae33-8d60-42ce-9fe7-14d4a8940254"; // Api Key
			
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
			    	tTime = ($intRate[0].getElementsByTagName("tmap:totalTime")[0].childNodes[0].nodeValue/60).toFixed(0);
					
					prtcl = new Tmap.Format.KML({extractStyles:true, extractAttributes:true}).read(prtcl); // read data(prtcl) and return vectorLayer(feature)
					
					/* if(count == 1){
						routeShortLayer = new Tmap.Layer.Vector("routeShort"); // create vectorLayer
						routeShortLayer.events.register("beforefeatureadded", routeShortLayer, onBeforeFeatureAdded);
					}else{
						routeSafeLayer = new Tmap.Layer.Vector("routeSafe");
						routeSafeLayer.events.register("beforefeatureadded", routeSafeLayer, onBeforeFeatureAdded);
					} */
					
					routeLayer = new Tmap.Layer.Vector("route"); // create vectorLayer
					routeLayer.events.register("beforefeatureadded", routeLayer, onBeforeFeatureAdded);
					
					function onBeforeFeatureAdded(e) {
			        	var style = {};
			        	
			        	if(count == 1)
			        		style.strokeColor = "#3396ff"; // apply hexnum color to stroke
			        	else
			        		style.strokeColor = "#ffcc00"; // apply hexnum color to stroke
			        	        		
			        	style.strokeOpacity = "1"; // stroke opacity
			        	style.strokeWidth = "7"; // stroke width
				        	
			        	e.feature.style = style;
			        }
					
					/* if(count == 1){
						routeShortLayer.addFeatures(prtcl); // add feature to routeLayer
						map.addLayer(routeShortLayer); // add routeLayer on map
					}else{
						routeSafeLayer.addFeatures(prtcl); // add feature to routeLayer
						map.addLayer(routeSafeLayer); // add routeLayer on map
					} */
					
					routeLayer.addFeatures(prtcl); // add feature to routeLayer
					map.addLayer(routeLayer); // add routeLayer on map
				},
				
				// if load fail to check error message in console
				error:function(request,status,error){
					console.log("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
				}
			});
			
			if(count != 1){
				safeRoute[routeCount] = routeLayer;
	 			routeCount = routeCount + 1;	
			}
			
			var arr = {'Distance':tDistance, 'Time':tTime, 'prtcl':prtcl, 'prtclString': prtclString, 'call':count};
			
			return arr; 
		}
		
		function distanceApi(Origin, Dest){
			// For circle radius
			$.ajax({
				method:"GET",
				url:"https://api2.sktelecom.com/tmap/routes/distance?version=1&format=xml", // straight distance calculate url
				async:false, 
				data:{
					// Start LonLat
					"startX" : Origin.lon,
					"startY" : Origin.lat,
					// End LonLat 
					"endX" : Dest.lon,
					"endY" : Dest.lat,
					// Set coordinate system
					"reqCoordType" : "WGS84GEO",
					// AppKey
					"appKey" : "2565ae33-8d60-42ce-9fe7-14d4a8940254"
				},
				// Data load Success
				success:function(response){
					prtcl = response;
					
					var prtclString = new XMLSerializer().serializeToString(prtcl);//xml to String	
				    xmlDoc = $.parseXML( prtclString ),
				    $xml = $( xmlDoc ),
				    $intRate = $xml.find("distanceInfo");
					
					distance = $intRate[0].getElementsByTagName("distance")[0].childNodes[0].nodeValue;
				},
				// Fail(Error Message)
				error:function(request,status,error){
					console.log("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
				}
			});
			
			return distance;
		}
		
		function makePassList(arr, i){
			
			var passList = "";
			
			if(arr[i].length > 2){					
				for(var j=1; j<arr[i].length-1; j++){
					if(j == arr[i].length-2)
						passList = passList + arr[i][j].lonlat.lon + "," + arr[i][j].lonlat.lat;
					else
						passList = passList + arr[i][j].lonlat.lon + "," + arr[i][j].lonlat.lat + "_";
				}
				
				return passList;
			}else{
				return null;
			}
		}
		
		function extractNode(prtcl, prtclString, passList) {
			
			passList = typeof passList !== 'undefined' ? passList : null;
			
			var len; // node length
			var tmpPoint = new Array();
			var pointnode = new Array(); // save point node
			
			xmlDoc = $.parseXML(prtclString),
			$xml = $( xmlDoc );
			
			// check pointnode
	    	$place = $xml.find("Placemark");				
	    	len = $place.length;				    	
	    	tmpPoint.push($place);
	    	
	    	for(var i=0; i<len; i++){
	    		pointnode[i] = tmpPoint[0][i].lastElementChild.childNodes[1].childNodes[0].nodeValue;
	    	}
	    	
			// pointnode data processing
			var newPoint = new Array();	
		
			// point split
			for(var i=0; i<len; i++){
				pointnode[i] = pointnode[i].split(" ");
				for(var j=0; j<pointnode[i].length; j++){
					if(pointnode[i][j] == ""){
						pointnode[i].splice(j, 1);
					}					
				}
			}
			
			// point 2D to 1D
			for(var i=0; i<pointnode.length-1; i++){
				if(i == 0){
					newPoint = pointnode[0];
				}else{
					newPoint = newPoint.concat(pointnode[i]);	
				}
			}
			
			// deduplication
			var uniqPoint = newPoint.reduce(function(a,b){
				if (a.indexOf(b) < 0 ) a.push(b);
				return a;
			},[]);
			
			// split lon and lat
			for(var i=0; i<uniqPoint.length; i++){
				uniqPoint[i] = uniqPoint[i].split(",");
			}
			
			// transform coordinate uniqPoint
			for(var i=0; i<uniqPoint.length; i++){
				uniqPoint[i] = new Tmap.LonLat(uniqPoint[i][0], uniqPoint[i][1]).transform("EPSG:3857", "EPSG:4326");
			}
			
			for(var i=0; i<pointnode.length; i++){
				console.log(pointnode[i].length);
				if(pointnode[i].length < 2){
					pointnode[i] = undefined;
				}
			}
			
			var dup = new Array();
			var tmp = new Array();
			var packet = new Array();
			var remove = new Array();
			var rev;
			
			for(var i=0; i<pointnode.length; i++){
				
				if(pointnode[i] == undefined){
					continue;
				}else{
					// reset dup, packet, tmp
					dup = new Array();
					//packet = new Array();
					tmp = new Array();
					
					// reverse once
					rev = pointnode[i].slice();
					rev = rev.reverse();
					
					console.log(rev);
					
					for(var j=0; j<pointnode.length; j++){
						if(i == j)
							continue;
						
						// compare reverse array with original array
						for(var k=0; k<rev.length; k++){
							if(pointnode[j] == undefined){
								break;
							}else{
								for(var l=0; l<pointnode[j].length; l++){
									if(rev[k] == pointnode[j][l]){
										console.log("(" + i + "," + k +") (" + j + "," + l +")");
										
										var inc = new Object();
										inc.i = j;
										inc.j = l;
										dup.push(inc);
									}
								}	
							}
						}
					}	
					
					console.log(dup);
					
					// extract dup to continued
					// dup.length > 1 & i same j contined number			
					if(dup.length > 1){
						comp = dup.shift();
						tmp.push(comp);
						
						while(dup.length > 0){
							
							comp2 = dup.shift();
							
							if(comp.i == comp2.i && comp.j+1 == comp2.j){
								tmp.push(comp2);
								comp = comp2;
							}else{
								if(tmp.length > 1){
									packet.push(tmp);
									tmp = new Array();
									tmp.push(comp2);
									comp = comp2;
								}else{
									tmp = new Array();
									tmp.push(comp2);
									comp = comp2;
								}						
							}
						}
					}
					
					if(tmp.length > 1){
						packet.push(tmp);	
					}			
					
					console.log(packet);	
				}
			}
			
			var arr = {"uniqPoint":uniqPoint, "prtcl":prtcl, "remove":packet, "pointnode":pointnode};
			
			return arr;
		}
		
		function distanceNotApi(fromLon, fromLat, toLon, toLat){
			var theta = fromLon - toLon;
			var dist = Math.sin(Math.radians(fromLat)) * Math.sin(Math.radians(toLat)) + 
					Math.cos(Math.radians(fromLat)) * Math.cos(Math.radians(toLat)) * Math.cos(Math.radians(theta));
			
			dist = Math.acos(dist);
			dist = Math.degrees(dist);
			
			dist = dist * 60 * 1.1515;
			dist = dist * 1.609344 * 1000;
			
			return dist;
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
	    	
			var positions = new Array();			
			
			<c:forEach items="${map}" var="loc">
				var cctv = new Object();	
				cctv.lon = "${loc.longitude}";
				cctv.lat = "${loc.latitude}";
				positions.push(cctv);
			</c:forEach>
			
			function NearByCCTV() {
				mapBounds = map.getExtent();
				
				mapArray = new Array();							
				for(var i=0; i<positions.length; i++){
					if(mapBounds.containsLonLat(new Tmap.LonLat(positions[i].lon, positions[i].lat).transform("EPSG:4326","EPSG:3857")))
						mapArray.push(positions[i]);
				}
				
				if(mapArray.length > 500){
					markercctvLayer.clearMarkers();
					
					for(var i=0; i<mapArray.length; i=i+Math.floor(mapArray.length/500)){
						var size = new Tmap.Size(10, 10); //아이콘 크기 설정
						var offset = new Tmap.Pixel(-(size.w / 2), -(size.h));  //아이콘 중심점 설정
						
						var icon = new Tmap.Icon('/resources/img/pointmark.png', size, offset); //마커 아이콘 설정
						
						marker = new Tmap.Markers(new Tmap.LonLat(mapArray[i].lon, mapArray[i].lat).transform("EPSG:4326", "EPSG:3857"), icon);
						markercctvLayer.addMarker(marker); // 마커 레이어에 마커 추가
					}
				}else {
					markercctvLayer.clearMarkers();
					
					for(var i=0; i<mapArray.length; i++){	
						var size = new Tmap.Size(10, 10); //아이콘 크기 설정
						var offset = new Tmap.Pixel(-(size.w / 2), -(size.h));  //아이콘 중심점 설정
						
						var icon = new Tmap.Icon('/resources/img/pointmark.png', size, offset); //마커 아이콘 설정
						
						marker = new Tmap.Markers(new Tmap.LonLat(mapArray[i].lon, mapArray[i].lat).transform("EPSG:4326", "EPSG:3857"), icon);
						markercctvLayer.addMarker(marker); // 마커 레이어에 마커 추가
					}
				}
			}
			
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
					
					if(this.classList.contains('1')){
						for(var i=1; i<map.layers.length; i++){
							if(map.layers[i].name == 'markercctvLayer')
								continue;
							
							map.layers[i].setVisibility(false);
						}
					}
					
					for(var i=0; i<classBtn.length; i++){
						classBtn[i].classList.remove('ACTIVE');
						classTab[i].classList.remove('ACTIVE');
					}					
					classTab[this.classList[0]-1].className += ' ACTIVE';
					if(this.classList[0] == 2){
						if(document.getElementsByClassName('Line Origin')[0].value == '')
							document.getElementsByClassName('Line Origin')[0].focus();
						if(map.layers.length > 1){
							for(var i=1; i<map.layers.length; i++)
								map.layers[i].setVisibility(true);
						}
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
						if(this.classList.contains('ACTIVE') == false){
							classNearBy[i].classList.remove('ACTIVE');
							markercctvLayer.clearMarkers();
						}
					}
					
					this.classList.toggle('ACTIVE');
					
					var mapBound, mapArray;
					if(this.classList.contains('CCTV')){
						if(this.classList.contains('ACTIVE')){						
							NearByCCTV();
							/* map.events.register('mouseup', map, function() {	
								console.log(mapArray.length);
							});	 */
						}else{
							markercctvLayer.clearMarkers();
						}
					}
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
				count = 0;
				
				distance = distanceApi(Origin, Dest);
				
				// radius
				radius = distance/2;
								
				// centerLonLat
				centerLon = (Origin.lon + Dest.lon) / 2;
				centerLat = (Origin.lat + Dest.lat) / 2;
				
				console.log('center [ ' + centerLon + ',' + centerLat + ' ]');
				
				// Change coordinate system for draw
				var drawcenter = new Tmap.LonLat(centerLon, centerLat).transform("EPSG:4326", "EPSG:3857");
				
				// Draw Circle pass by Start and End
				circle = new Tmap.Geometry.Circle(drawcenter.lon, drawcenter.lat, radius, {unit:"m"}); // Create circle
				
				circleFeature = new Tmap.Feature.Vector(circle, null, styleCircle); // create circleVector
				/* vectorLayer.addFeatures(circleFeature); // Add circle to vectorLayer */
				
				/* map.zoomToExtent(vectorLayer.getDataExtent());//map의 zoom을 routeLayer의 영역에 맞게 변경합니다. */
				
				markerLayer.clearMarkers();
				
				// Reset icon size
				size = new Tmap.Size(22, 25.5);  
				offset = new Tmap.Pixel(-(size.w / 2), -(size.h));
								
				// circle round points
				var roundPoints = circleFeature.geometry.getVertices(); // Get roundPoints
				
				var compRound = new Array();
				for(var i=0; i<roundPoints.length; i++){
					compRound[i] = new Tmap.LonLat(roundPoints[i].x, roundPoints[i].y).transform("EPSG:3857", "EPSG:4326"); // To compare
				}
				
				var markerArray = new Array();
				// cctv Marker				
				for(var i=0; i<positions.length; i++){
					for(var j=0; j<roundPoints.length; j++){
						if(compRound[j].lon < positions[i].lon && compRound[j].lat < positions[i].lat && centerLon > positions[i].lon && centerLat > positions[i].lat){
							
							icon = new Tmap.Icon('/resources/img/marker_cctv.png', size, offset); // Set marker icon
							marker = new Tmap.Marker(new Tmap.LonLat(positions[i].lon, positions[i].lat).transform("EPSG:4326", "EPSG:3857"), icon); // Change coordinate system
							markerArray[i] = new Tmap.LonLat(positions[i].lon, positions[i].lat);
							markerLayer.addMarker(marker); // Add marker to markerLayer
							
						}else if(compRound[j].lon < positions[i].lon && compRound[j].lat > positions[i].lat && centerLon > positions[i].lon && centerLat < positions[i].lat){
							
							icon = new Tmap.Icon('/resources/img/marker_cctv.png', size, offset); // Set marker icon
							marker = new Tmap.Marker(new Tmap.LonLat(positions[i].lon, positions[i].lat).transform("EPSG:4326", "EPSG:3857"), icon); // Change coordinate system
							markerArray[i] = new Tmap.LonLat(positions[i].lon, positions[i].lat);
							markerLayer.addMarker(marker); // Add marker to markerLayer
							
						}else if(compRound[j].lon > positions[i].lon && compRound[j].lat < positions[i].lat && centerLon < positions[i].lon && centerLat > positions[i].lat){
							
							icon = new Tmap.Icon('/resources/img/marker_cctv.png', size, offset); // Set marker icon
							marker = new Tmap.Marker(new Tmap.LonLat(positions[i].lon, positions[i].lat).transform("EPSG:4326", "EPSG:3857"), icon); // Change coordinate system
							markerArray[i] = new Tmap.LonLat(positions[i].lon, positions[i].lat);
							markerLayer.addMarker(marker); // Add marker to markerLayer
							
						}else if(compRound[j].lon > positions[i].lon && compRound[j].lat > positions[i].lat && centerLon < positions[i].lon && centerLat < positions[i].lat){
							
							icon = new Tmap.Icon('/resources/img/marker_cctv.png', size, offset); // Set marker icon
							marker = new Tmap.Marker(new Tmap.LonLat(positions[i].lon, positions[i].lat).transform("EPSG:4326", "EPSG:3857"), icon); // Change coordinate system
							markerArray[i] = new Tmap.LonLat(positions[i].lon, positions[i].lat);
							markerLayer.addMarker(marker); // Add marker to markerLayer
							
						}
					}
				}				
				
				// ShortestPath
				result = shortestPathApi(Origin, Dest, count);
				this.className += ' ACTIVE'; 
				
				if(result.Distance >= 1000)
					$('.Shortest .Distance').text((result.Distance/1000).toFixed(1)+"km");
				else
					$('.Shortest .Distance').text(result.Distance+"m");
				
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
					}else if(description.includes("도착")){
						continue; 
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
				
				// extractNode
				var extract = extractNode(result.prtcl, result.prtclString);
				var uniqPoint = extract.uniqPoint;
				
				// the nearest nodePoint in cctv				
				// filter empty array
				var filterMarker = markerArray.filter(function (el) {
					return el != null;
				});
				
				// Distance between cctv to nodePoint
				var Points = new Array();
				var matrixDist, minDist, minIndex;
				
				for(var i=0; i<filterMarker.length; i++){
					for(var j=0; j<uniqPoint.length; j++){
						
						matrixDist = distanceNotApi(filterMarker[i].lon, filterMarker[i].lat, uniqPoint[j].lon, uniqPoint[j].lat);
						
						if(j == 0){
							minDist = matrixDist;
							minIndex = 0;
						}else{
							if(minDist > matrixDist){
								minDist = matrixDist;
								minIndex = j;
							}else{
								minDist = minDist;
								minIndex = minIndex;								
							}
						}
					}
					
					var inCircle = new Object();
					inCircle.nodeNum = minIndex;
					inCircle.nodeLonLat = uniqPoint[minIndex];
					inCircle.cctvNum = i;
					inCircle.cctvLonLat = filterMarker[i];
					inCircle.distance = minDist;
					Points.push(inCircle);
					
					console.log('between cctv ' + i + ' to nodePoint ' + minIndex + ' min distance : ' + minDist);
				}
				
				/* size = new Tmap.Size(16, 16);  
				offset = new Tmap.Pixel(-(size.w/2), -(size.h/2));
				
				markerpointLayer = new Tmap.Layer.Markers();// create markerLayer
				map.addLayer(markerpointLayer); // add markerLayer
				
				var list = new Array(); //포인트를 저장할 배열
				
				for(var i=0; i<Points.length; i++){
					icon = new Tmap.Icon('http://topopen.tmap.co.kr/imgs/point.png', size, offset); // Set marker icon
					marker = new Tmap.Marker(new Tmap.LonLat(Points[i].nodeLonLat.lon, Points[i].nodeLonLat.lat).transform("EPSG:4326", "EPSG:3857"), icon); // Change coordinate system
					markerpointLayer.addMarker(marker); // Add marker to markerLayer
					
					var line = new Array();
					line.push(new Tmap.Geometry.Point(Points[i].nodeLonLat.lon, Points[i].nodeLonLat.lat).transform("EPSG:4326", "EPSG:3857"));
					line.push(new Tmap.Geometry.Point(Points[i].cctvLonLat.lon, Points[i].cctvLonLat.lat).transform("EPSG:4326", "EPSG:3857"));
					list.push(line);
				}
				
				for(var i=0; i<list.length; i++){
					console.log(list[i]);
					var lineString = new Tmap.Geometry.LineString(list[i]);
					var style_bold = {strokeWidth: 5}; // 선 굵기 지정
					var mLineFeature = new Tmap.Feature.Vector(lineString, null, style_bold); // 백터 생성
					
					var vector_Layer = new Tmap.Layer.Vector("vectorLayerID"); // 백터 레이어 생성
					map.addLayer(vector_Layer); // 지도에 백터 레이어 추가
					 
					vector_Layer.addFeatures([mLineFeature]); // 백터를 백터 레이어에 추가
				} */
				
				// sorting distance asc
				Points.sort(function(a, b) {
				    return a.distance - b.distance;
				});
				
				console.log("length : " + Points.length);
				
				// slice ten values
				if(Points.length > 10)
					Points = Points.slice(0, 10);
				else
					Points = Points; 
					
				//Points = Points.slice(0, Points.length/3);
				
				// sorting nodeNum asc
				Points.sort(function(a, b) {
				    return a.nodeNum - b.nodeNum;
				});				
				
				// marking
				var sortMark;
				
				size = new Tmap.Size(25, 29);  
				offset = new Tmap.Pixel(-(size.w / 2), -(size.h));
				
				for(var i=0; i<Points.length; i++){
					sortMark = new Tmap.LonLat(Points[i].cctvLonLat.lon, Points[i].cctvLonLat.lat).transform("EPSG:4326", "EPSG:3857");
					icon = new Tmap.Icon('/resources/img/mark'+(i+1)+'.png', size, offset); // Set marker icon
					var marker = new Tmap.Marker(sortMark, icon); // Change coordinate system
					markerSafeLayer.addMarker(marker); // Add marker to markerLayer
				}
				
				// unshift startLonLat and push endLonLat				
				for(var i=0; i<Points.length; i++){
					Points[i] = Points[i].cctvLonLat;
				}
				
				Points.unshift(new Tmap.LonLat(Origin.lon, Origin.lat));
				Points.push(new Tmap.LonLat(Dest.lon, Dest.lat));
				
				// next nearest to next nearest (matrix?)
				var minDista, matrixDista, minInd;
				var minArray = new Array();
				
				for(var i=0; i<Points.length-1; i++){
					for(var j=i+1; j<Points.length; j++){
						matrixDista = distanceNotApi(Points[i].lon, Points[i].lat, Points[j].lon, Points[j].lat);
						if(j == i+1){
							minDista = matrixDista;
							minInd = i+1;
						}else{
							if(minDista > matrixDista){
								minDista = matrixDista;
								minInd = j;
							}else{
								minDista = minDista;
								minInd = minInd;
							}							  
						}
						
						console.log(i + " and " + j + " matrixDista : " + matrixDista + " minInd : " + minInd);
					}
					
					var test = new Object();
					test.ind = minInd;
					test.lonlat = new Tmap.LonLat(Points[minInd].lon, Points[minInd].lat);
					minArray.push(test);
										
					console.log(i + " and " + minInd + " minDista : " + minDista);
					
					i = minInd - 1;
				}
				
				var fir = new Object();
				fir.ind = 0;
				fir.lonlat = new Tmap.LonLat(Origin.lon, Origin.lat);	
				minArray.unshift(fir);
				
				markerSafeLayer.clearMarkers();
				
				for(var i=1; i<minArray.length-1; i++){
					console.log(minArray[i]);
					sortMark = new Tmap.LonLat(minArray[i].lonlat.lon, minArray[i].lonlat.lat).transform("EPSG:4326", "EPSG:3857");
					icon = new Tmap.Icon('/resources/img/mark'+i+'.png', size, offset); // Set marker icon
					var marker = new Tmap.Marker(sortMark, icon); // Change coordinate system
					markerSafeLayer.addMarker(marker); // Add marker to markerLayer
				}
				
				// divide Points
				var roadPoints = new Array();
				var divIndex = 0;
				
				for(var i=0; i<minArray.length; i=i+4){
					roadPoints[divIndex] = minArray.slice(i, i+5);
					divIndex = divIndex + 1;
				}
				
				if(roadPoints[roadPoints.length-1].length < 2)
					roadPoints.pop();
				
				// findsaferoad
				var passList = "";
				var index = 0;
				
				var tDistance = 0, tTime = 0, count = 1;
				
				var saferoad = setInterval(function() {
					
					// make passList
					passList = makePassList(roadPoints, index);
					console.log("passList " + (index+1) + " : " + passList);
					
					// path api
					var pathInfo = shortestPathApi(roadPoints[index][0].lonlat, roadPoints[index][roadPoints[index].length-1].lonlat, count, passList);
					callCount = pathInfo.call;
					
					console.log('dist : ' + pathInfo.Distance + ' time : ' + pathInfo.Time);
					tDistance = tDistance + Number(pathInfo.Distance);
					tTime = tTime + Number(pathInfo.Time);
					
					// extractNode
					var extract = extractNode(pathInfo.prtcl, pathInfo.prtclString, passList);
					var prtcl = extract.prtcl;
					
					size = new Tmap.Size(18, 28);  
					offset = new Tmap.Pixel(-(size.w / 2), -(size.h));
					
					routeLayer.addFeatures(prtcl); // add feature to routeLayer
					map.addLayer(routeLayer); // add routeLayer on map 
										
					index = index + 1;		
					
					prtclString = pathInfo.prtclString;
					
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
						}else if(description.includes("도착")){
							continue; 
						}else{
							icon = "<img src='/resources/img/upload.svg' width=24 height=24>";
							innerHtml += "<li>"+icon+""+description+"</li>";
						}
					}				
					
					Detail = document.getElementsByClassName('Detail')[1];
					Detail.children[0].innerHTML = innerHtml;
					Detail.style.paddingBottom = "20px";
					
					if(index == roadPoints.length){
						if(tDistance >= 1000)
							$('.Safe .Distance').text((tDistance/1000).toFixed(1)+"km");
						else
							$('.Safe .Distance').text(tDistance+"m");
						
						$('.Safe .Time').text(tTime+"분");
						
						clearInterval(saferoad);
					}
					
				}, 100);
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
						<td><button class="1 Btn ACTIVE">검색</button></td>
						<td><button class="2 Btn">길찾기</button></td>						
					</tr>
				</table>
			</div>
		</div>
		<div class="Body">
			<div class="1 Tab ACTIVE">
				<div class="BeforeSearch">
					<div class="Title">
						주변탐색
					</div>
					<div class="Body">
						<table>
							<tr>
								<td><button class="NearBy CCTV"><img src="/resources/img/security-camera.svg" ></button></td>
								<td><button class="NearBy StreetLamp"><img src="/resources/img/streetLamp.svg"></button></td>
								<td><button class="NearBy Bell"><img src="/resources/img/emergencyBell.svg"></button></td>
								<td><button class="NearBy Police "><img src="/resources/img/policeStation.svg"></button></td>
								<td><button class="NearBy Fire"><img src="/resources/img/fireStation.svg"></button></td>
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
			<div class="2 Tab">
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
								<div class="Time"></div>
								<div class="Distance"></div>
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
								<div class="Time"></div>
								<div class="Distance"></div>
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