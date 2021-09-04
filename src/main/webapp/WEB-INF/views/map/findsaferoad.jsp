<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>Insert title here</title>
	<script src="https://api2.sktelecom.com/tmap/js?version=1&format=javascript&appKey=e5e6c714-9b68-48fe-9ff8-46d3dcc0e411"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
    <script type="text/javascript">
    	var map, marker, markerLayer;
    	
    	var circle, circleFeature, vectorLayer;
    	
    	// cctv dobong (533)
    	var count = 0;
		var positions = new Array();			
		
		<c:forEach items="${map}" var="loc">
			var cctv = new Object();	
			cctv.lon = "${loc.longitude}";
			cctv.lat = "${loc.latitude}";
			positions.push(cctv);
			count = count + 1;
		</c:forEach>
    	
    	function initTmap() {
    		
    		console.log('cctv count : ' + count);
    		
			map = new Tmap.Map({
					div : 'map_div', 	// map_div
					width : "100%", 	// Set map width
					height : "100vh", 	// Set map height
				});
			
			map.setCenter(new Tmap.LonLat("126.83679367832319", "37.55452233461458").transform("EPSG:4326", "EPSG:3857"), 17); 

			markerLayer = new Tmap.Layer.Markers("marker"); // Create markerLayer
			map.addLayer(markerLayer); // Add markerLayer to map
			
			vectorLayer = new Tmap.Layer.Vector(); // Create vectorLayer
			map.addLayers([vectorLayer]); // Add vectorLayer to map
			
			map.events.register("click", map, onClick); // Click Event
		}
    	
    	var clickcount = 0;
    	
    	// For marker style
    	var icon, size, offset;    	
    	
    	// Start, End LonLat and Pixel 
    	var startLon, startLat, endLon, endLat; // startPixel, endPixel;
    	
    	// For draw circle
    	var centerLon, centerLat, radius, distance;
    	var styleCircle = {
				fillColor:"#FF0000",
				fillOpacity: 0,
				strokeColor: "#FF0000",
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
		var routeLayerArr = new Array();
		
		function shortestPathApi(fromLon, fromLat, toLon, toLat, count, passList) {
			
			count = count + 1;
			
			// default parameter passList
			passList = typeof passList !== 'undefined' ? passList : null;		
			
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
					startX : fromLon,
					startY : fromLat,
					// End LonLat
					endX : toLon,
					endY : toLat,
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
			    	
			    	tDistance = ($intRate[0].getElementsByTagName("tmap:totalDistance")[0].childNodes[0].nodeValue/1000).toFixed(1);
			    	tTime = ($intRate[0].getElementsByTagName("tmap:totalTime")[0].childNodes[0].nodeValue/60).toFixed(0);
					
					prtcl = new Tmap.Format.KML({extractStyles:true, extractAttributes:true}).read(prtcl); // read data(prtcl) and return vectorLayer(feature)
					routeLayer = new Tmap.Layer.Vector("route"); // create vectorLayer
					
					// to read/write standard data format(KML) class
					// to occur event just before add vectorLayer(feature)
					routeLayer.events.register("beforefeatureadded", routeLayer, onBeforeFeatureAdded);
					
					function onBeforeFeatureAdded(e) {
			        	var style = {};
			        	
			        	if(count == 1)
			        		style.strokeColor = "#3396ff"; // apply hexnum color to stroke
			        	else
			        		style.strokeColor = "#ff0000"; // apply hexnum color to stroke
			        	        		
			        	style.strokeOpacity = "1"; // stroke opacity
			        	style.strokeWidth = "5"; // stroke width
				        	
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
			
			routeLayerArr[routeCount] = routeLayer;
			routeCount = routeCount + 1;
			
			var arr = {'prtcl':prtcl, 'prtclString':prtclString, 'tDistance':tDistance, 'tTime':tTime, 'call':count};
			
			return arr;
		}
		
		function distanceApi(startLon, startLat, endLon, endLat){
			// For circle radius
			$.ajax({
				method:"GET",
				url:"https://api2.sktelecom.com/tmap/routes/distance?version=1&format=xml", // straight distance calculate url
				async:false, 
				data:{
					// Start LonLat
					"startX" : startLon,
					"startY" : startLat,
					// End LonLat 
					"endX" : endLon,
					"endY" : endLat,
					// Set coordinate system
					"reqCoordType" : "WGS84GEO",
					// AppKey
					"appKey" : "e5e6c714-9b68-48fe-9ff8-46d3dcc0e411"
				},
				// Data load Success
				success:function(response){
					prtcl = response;
					
					var prtclString = new XMLSerializer().serializeToString(prtcl);//xml to String	
				    xmlDoc = $.parseXML( prtclString ),
				    $xml = $( xmlDoc ),
				    $intRate = $xml.find("distanceInfo");
					
					distance = $intRate[0].getElementsByTagName("distance")[0].childNodes[0].nodeValue;
					
					$("#result").text("출발지 도착지 간의 직선 거리 : " + distance + "m");
				},
				// Fail(Error Message)
				error:function(request,status,error){
					console.log("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
				}
			});
			
			return distance;
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
    	
    	function onClick(e) {
    		
    		console.log('click : ' + clickcount);
    		var callCount;
    		
    		if(clickcount == 0){
    			
    			// Reset markerArray 			
    			markerArray = new Array();
    			
    			// Start, End Marker style
    			size = new Tmap.Size(18, 29); // Set icon size
				offset = new Tmap.Pixel(-(size.w / 2), -size.h);
    			
    			// Start Marker
				clonlat = map.getLonLatFromViewPortPx(e.xy).transform("EPSG:3857", "EPSG:4326"); // Use Click LonLat
				
				startLon = clonlat.lon;
				startLat = clonlat.lat;
				
				//startPixel = map.getPixelFromLonLat(new Tmap.LonLat(startLon, startLat).transform("EPSG:4326", "EPSG:3857")); // LonLat to Pixel
				//console.log(startPixel); // Print StartPixel
				
				icon = new Tmap.IconHtml('<img src=http://tmapapis.sktelecom.com/upload/tmap/marker/pin_r_m_s.png />', size, offset); // Set marker icon
				marker = new Tmap.Marker(new Tmap.LonLat(startLon, startLat).transform("EPSG:4326", "EPSG:3857"), icon); // Change coordinate system
				markerLayer.addMarker(marker); // Add marker to markerLayer
    			
    		}else if(clickcount == 1){
    			
    			callCount = 0;
    			
    			// End Marker
				clonlat = map.getLonLatFromViewPortPx(e.xy).transform("EPSG:3857", "EPSG:4326"); // Use Click LonLat
				
				endLon = clonlat.lon;
				endLat = clonlat.lat;
				
				//endPixel = map.getPixelFromLonLat(new Tmap.LonLat(endLon, endLat).transform("EPSG:4326", "EPSG:3857")); // LonLat to Pixel
				//console.log(endPixel); // Print EndPixel
				
				icon = new Tmap.IconHtml('<img src=http://tmapapis.sktelecom.com/upload/tmap/marker/pin_r_m_e.png />', size, offset); // Set marker icon
				marker = new Tmap.Marker(new Tmap.LonLat(endLon, endLat).transform("EPSG:4326", "EPSG:3857"), icon); // Change coordinate system
				markerLayer.addMarker(marker); // Add marker to markerLayer
				
				distance = distanceApi(startLon, startLat, endLon, endLat);
				
				console.log('using api distance : ' + distance);
				
				// radius
				radius = distance/2;
				
				// Distance not using api
				dist = distanceNotApi(startLon, startLat, endLon, endLat);		
				
				console.log('not using api distance : ' + dist);
								
				// centerLonLat
				centerLon = (startLon + endLon) / 2;
				centerLat = (startLat + endLat) / 2;
				
				console.log('center [ ' + centerLon + ',' + centerLat + ' ]');
				
				// Change coordinate system for draw
				var drawcenter = new Tmap.LonLat(centerLon, centerLat).transform("EPSG:4326", "EPSG:3857");
				
				// Center Marker
				icon = new Tmap.IconHtml('<img src=http://tmapapis.sktelecom.com/upload/tmap/marker/pin_r_m_c.png />', size, offset); // Set marker icon
				marker = new Tmap.Marker(drawcenter, icon); // Change coordinate system
				markerLayer.addMarker(marker); // Add marker to markerLayer
				
				// Draw Circle pass by Start and End
				circle = new Tmap.Geometry.Circle(drawcenter.lon, drawcenter.lat, radius, {unit:"m"}); // Create circle
				
				circleFeature = new Tmap.Feature.Vector(circle, null, styleCircle); // create circleVector
				vectorLayer.addFeatures(circleFeature); // Add circle to vectorLayer
				
				// Reset icon size
				size = new Tmap.Size(18, 28);  
				offset = new Tmap.Pixel(-(size.w / 2), -(size.h));
								
				// circle round points
				var roundPoints = circleFeature.geometry.getVertices(); // Get roundPoints
				
				for(var i=0; i<roundPoints.length; i++){
					
					compRound[i] = new Tmap.LonLat(roundPoints[i].x, roundPoints[i].y).transform("EPSG:3857", "EPSG:4326"); // To compare
					//markRound[i] = new Tmap.LonLat(roundPoints[i].x, roundPoints[i].y); // To draw
				}
				
				// cctv Marker				
				for(var i=0; i<positions.length; i++){
					for(var j=0; j<roundPoints.length; j++){
						if(compRound[j].lon < positions[i].lon && compRound[j].lat < positions[i].lat && centerLon > positions[i].lon && centerLat > positions[i].lat){
							
							icon = new Tmap.IconHtml('<img src=http://tmapapis.sktelecom.com/upload/tmap/marker/pin_b_m_a.png />', size, offset); // Set marker icon
							marker = new Tmap.Marker(new Tmap.LonLat(positions[i].lon, positions[i].lat).transform("EPSG:4326", "EPSG:3857"), icon); // Change coordinate system
							markerArray[i] = new Tmap.LonLat(positions[i].lon, positions[i].lat);
							markerLayer.addMarker(marker); // Add marker to markerLayer
							
						}else if(compRound[j].lon < positions[i].lon && compRound[j].lat > positions[i].lat && centerLon > positions[i].lon && centerLat < positions[i].lat){
							
							icon = new Tmap.IconHtml('<img src=http://tmapapis.sktelecom.com/upload/tmap/marker/pin_b_m_a.png />', size, offset); // Set marker icon
							marker = new Tmap.Marker(new Tmap.LonLat(positions[i].lon, positions[i].lat).transform("EPSG:4326", "EPSG:3857"), icon); // Change coordinate system
							markerArray[i] = new Tmap.LonLat(positions[i].lon, positions[i].lat);
							markerLayer.addMarker(marker); // Add marker to markerLayer
							
						}else if(compRound[j].lon > positions[i].lon && compRound[j].lat < positions[i].lat && centerLon < positions[i].lon && centerLat > positions[i].lat){
							
							icon = new Tmap.IconHtml('<img src=http://tmapapis.sktelecom.com/upload/tmap/marker/pin_b_m_a.png />', size, offset); // Set marker icon
							marker = new Tmap.Marker(new Tmap.LonLat(positions[i].lon, positions[i].lat).transform("EPSG:4326", "EPSG:3857"), icon); // Change coordinate system
							markerArray[i] = new Tmap.LonLat(positions[i].lon, positions[i].lat);
							markerLayer.addMarker(marker); // Add marker to markerLayer
							
						}else if(compRound[j].lon > positions[i].lon && compRound[j].lat > positions[i].lat && centerLon < positions[i].lon && centerLat < positions[i].lat){
							
							icon = new Tmap.IconHtml('<img src=http://tmapapis.sktelecom.com/upload/tmap/marker/pin_b_m_a.png />', size, offset); // Set marker icon
							marker = new Tmap.Marker(new Tmap.LonLat(positions[i].lon, positions[i].lat).transform("EPSG:4326", "EPSG:3857"), icon); // Change coordinate system
							markerArray[i] = new Tmap.LonLat(positions[i].lon, positions[i].lat);
							markerLayer.addMarker(marker); // Add marker to markerLayer
							
						}
					}
				}
				
				// shortestPathApi
				var pathInfo = shortestPathApi(startLon, startLat, endLon, endLat, callCount);
				callCount = pathInfo.call;
				
				$("#shortestRoad").text("최단거리 : " + pathInfo.tDistance + "km 시간 : " + pathInfo.tTime + "분");
				
				// extractNode
				var extract = extractNode(pathInfo.prtcl, pathInfo.prtclString);
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
								
				size = new Tmap.Size(18, 28);  
				offset = new Tmap.Pixel(-(size.w / 2), -(size.h));
				
				for(var i=0; i<Points.length; i++){
				
					sortMark = new Tmap.LonLat(Points[i].cctvLonLat.lon, Points[i].cctvLonLat.lat).transform("EPSG:4326", "EPSG:3857");
					
					icon = new Tmap.IconHtml('<img src=http://tmapapis.sktelecom.com/upload/tmap/marker/pin_r_m_'+i+'.png />', size, offset); // Set marker icon
					marker = new Tmap.Marker(sortMark, icon); // Change coordinate system
					markerLayer.addMarker(marker); // Add marker to markerLayer
				}
				
				// unshift startLonLat and push endLonLat				
				for(var i=0; i<Points.length; i++){
					Points[i] = Points[i].cctvLonLat;
				}
				
				Points.unshift(new Tmap.LonLat(startLon, startLat));
				Points.push(new Tmap.LonLat(endLon, endLat));
				
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
				fir.lonlat = new Tmap.LonLat(startLon, startLat);	
				minArray.unshift(fir);
				
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
				
				var tDistance = 0, tTime = 0;
				
				var saferoad = setInterval(function() {
					
					// make passList
					passList = makePassList(roadPoints, index);
					console.log("passList " + (index+1) + " : " + passList);
					
					// path api
					var pathInfo = shortestPathApi(roadPoints[index][0].lonlat.lon, roadPoints[index][0].lonlat.lat, roadPoints[index][roadPoints[index].length-1].lonlat.lon, roadPoints[index][roadPoints[index].length-1].lonlat.lat, callCount, passList);
					callCount = pathInfo.call;
					
					console.log('dist : ' + pathInfo.tDistance + ' time : ' + pathInfo.tTime);
					tDistance = tDistance + Number(pathInfo.tDistance);
					tTime = tTime + Number(pathInfo.tTime);
					
					// extractNode
					var extract = extractNode(pathInfo.prtcl, pathInfo.prtclString, passList);
					var prtcl = extract.prtcl;
					var remove = extract.remove;
					var pointnode = extract.pointnode;
					
					console.log(prtcl);
					console.log(remove);
					
					for(var i=0; i<remove.length; i++){
						if(remove[i][0].j == 0){
							//prtcl[remove[i][0].i].geometry.components.splice(remove[i][0].j, remove[i].length);
							continue;
						}else{
							for(var j=0; j<remove[i].length-1; j++){
								//prtcl[remove[i][0].i].geometry.components.pop();	
							}
						}
					}
					
					size = new Tmap.Size(18, 28);  
					offset = new Tmap.Pixel(-(size.w / 2), -(size.h));
					
					icon = new Tmap.IconHtml('<img src=http://tmapapis.sktelecom.com/upload/tmap/marker/pin_r_m_a.png />', size, offset); // Set marker icon
					label = new Tmap.Label("1111");
					marker = new Tmap.Marker(new Tmap.LonLat(14141024, 4530869), icon, label); // Change coordinate system
					marker.events.register("mouseover", marker, onOverMarker);//마커 마우스 오버 이벤트 등록
					marker.events.register("mouseout", marker, onMarkerOut);//마커 마우스 아웃 이벤트 등록
					markerLayer.addMarker(marker); // Add marker to markerLayer
					
					function onOverMarker (evt){
					    this.popup.show();
					}
					
					function onMarkerOut(evt){
					    this.popup.hide();
					}
					
					routeLayer.addFeatures(prtcl); // add feature to routeLayer
					map.addLayer(routeLayer); // add routeLayer on map 
										
					index = index + 1;					
					
					if(index == roadPoints.length){
						$("#shortestSafeRoad").text("총 거리 : " + tDistance.toFixed(1) + "km 시간 : " + tTime + "분");
						clearInterval(saferoad);
					}
					
				}, 500);
							
				
    		}else{
    			
    			// Remove all marker
    			markerLayer.clearMarkers();
    			
    			// Remove circle
    			vectorLayer.removeAllFeatures();
    			
    			// Remove routeLayer
    			for(var i=0; i<routeCount; i++){
    				routeLayerArr[i].destroy();
    			}
    			
    			// Reset clickcount
    			clickcount = -1;
    		}
    		
    		clickcount = clickcount + 1;
    		
    	}
    	 
		$(function() {
			initTmap(); 
		});
    </script>
</head>
<body>
	<div id='map_div'></div>
	<p id='result'></p>
	<p id='shortestRoad'></p>
	<p id='shortestSafeRoad'></p>
</body>
</html>
