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
		var map, marker, markerLayer, circleFeature;
		var markerArray = new Array();
		var vector_layer = new Tmap.Layer.Vector('Tmap Vector Layer');
	
		function initTmap() {
			
			map = new Tmap.Map({div:'map_div',
				width:'100%',
				height:'850px'
				});

			map.setCenter(new Tmap.LonLat("127.04090314262496", "37.65350370915024").transform("EPSG:4326", "EPSG:3857"), 15);
			
			map.events.register("click", map, onClick);
		}
		
		function onClick(e){
			vector_layer.destroy();
			
			for (var i = 0; i < markerArray.length; i++) {
				markerLayer.removeMarker(markerArray[i]);
			}
			
			var clonlat = map.getLonLatFromViewPortPx(e.xy).transform("EPSG:3857", "EPSG:4326");
			
			vector_layer = new Tmap.Layer.Vector('Tmap Vector Layer');
			map.addLayers([vector_layer]);
			
			var coord = new Tmap.LonLat(clonlat.lon, clonlat.lat).transform("EPSG:4326", "EPSG:3857");
			var circle = new Tmap.Geometry.Circle(coord.lon, coord.lat, 500);
			
			var style_red = {
				fillColor:"#FF0000",
				fillOpacity:0.2,
				strokeColor: "#FF0000",
				strokeWidth: 3,
				strokeDashstyle: "solid",
				pointRadius: 60
			};
			
			circleFeature = new Tmap.Feature.Vector(circle, null, style_red);
			vector_layer.addFeatures([circleFeature]);
			
			markerLayer = new Tmap.Layer.Markers();
			map.addLayer(markerLayer);
	   		
	   		var size = new Tmap.Size(12, 19); 
			var offset = new Tmap.Pixel(-(size.w / 2), -(size.h));
			
			var positions = new Array();			
			
			<c:forEach items="${map}" var="loc">
				var cctv = new Object();	
				cctv.lon = "${loc.longitude}";
				cctv.lat = "${loc.latitude}";
				positions.push(cctv);				
			</c:forEach>
			
			console.log(positions[0]);

			var cctvlonlat = new Array();
			var cctvmarklonlat = new Array();
			
			for(var i=0; i<positions.length; i++){
				cctvlonlat[i] = new Tmap.LonLat(positions[i].lon, positions[i].lat);
				cctvmarklonlat [i] = new Tmap.LonLat(positions[i].lon, positions[i].lat).transform("EPSG:4326", "EPSG:3857");
			}			
			
			var marklonlat = new Array();
			var comparelonlat = new Array();
			
			for(var i=0; i<circleFeature.geometry.getVertices().length; i++){
				comparelonlat[i] = new Tmap.LonLat(circleFeature.geometry.getVertices()[i].x, circleFeature.geometry.getVertices()[i].y).transform("EPSG:3857", "EPSG:4326");
				marklonlat[i] = new Tmap.LonLat(circleFeature.geometry.getVertices()[i].x, circleFeature.geometry.getVertices()[i].y);				
			}
			
			
			for(var j=0; j<comparelonlat.length; j++){
				
					var icon = new Tmap.Icon('http://tmapapis.sktelecom.com/upload/tmap/marker/pin_b_m_a.png',size, offset);
					marker = new Tmap.Marker(marklonlat[j], icon);
					markerArray.push(marker);
					markerLayer.addMarker(marker); 
				
				
			}
			
			/*
			for(var i=0; i<cctvlonlat.length; i++){
				for(var j=0; j<comparelonlat.length; j++){
					if(comparelonlat[j].lon < clonlat.lon && comparelonlat[j].lat < clonlat.lat){
						if(cctvlonlat[i].lon >= comparelonlat[j].lon && cctvlonlat[i].lat >= comparelonlat[j].lat 
								&& clonlat.lon >= cctvlonlat[i].lon && clonlat.lat >= cctvlonlat[i].lat){
							var icon = new Tmap.Icon('http://tmapapis.sktelecom.com/upload/tmap/marker/pin_b_m_a.png',size, offset);
							marker = new Tmap.Marker(cctvmarklonlat[i], icon);
							markerArray.push(marker);
							markerLayer.addMarker(marker); 
						}
					}else if(comparelonlat[j].lon > clonlat.lon && comparelonlat[j].lat < clonlat.lat){
						if(cctvlonlat[i].lon <= comparelonlat[j].lon && cctvlonlat[i].lat >= comparelonlat[j].lat 
								&& clonlat.lon <= cctvlonlat[i].lon && clonlat.lat >= cctvlonlat[i].lat){
							var icon = new Tmap.Icon('http://tmapapis.sktelecom.com/upload/tmap/marker/pin_b_m_a.png',size, offset);
							marker = new Tmap.Marker(cctvmarklonlat[i], icon);
							markerArray.push(marker);
							markerLayer.addMarker(marker); 
						}
					}else if(comparelonlat[j].lon < clonlat.lon && comparelonlat[j].lat > clonlat.lat){
						if(cctvlonlat[i].lon >= comparelonlat[j].lon && cctvlonlat[i].lat <= comparelonlat[j].lat 
								&& clonlat.lon >= cctvlonlat[i].lon && clonlat.lat <= cctvlonlat[i].lat){
							var icon = new Tmap.Icon('http://tmapapis.sktelecom.com/upload/tmap/marker/pin_b_m_a.png',size, offset);
							marker = new Tmap.Marker(cctvmarklonlat[i], icon);
							markerArray.push(marker);
							markerLayer.addMarker(marker); 
						}
					}else if(comparelonlat[j].lon > clonlat.lon && comparelonlat[j].lat > clonlat.lat){
						if(cctvlonlat[i].lon <= comparelonlat[j].lon && cctvlonlat[i].lat <= comparelonlat[j].lat 
								&& clonlat.lon <= cctvlonlat[i].lon && clonlat.lat <= cctvlonlat[i].lat){
							var icon = new Tmap.Icon('http://tmapapis.sktelecom.com/upload/tmap/marker/pin_b_m_a.png',size, offset);
							marker = new Tmap.Marker(cctvmarklonlat[i], icon);
							markerArray.push(marker);
							markerLayer.addMarker(marker); 
						}
					}	
				}
			}
			*/
		}
	
		$(function (){
			initTmap();
		});
	</script>
</head>
<body>
	<div id="map_div">
	
	</div>
</body>
</html>