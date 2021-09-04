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
		var count = 0;
		
		var positions = new Array();			
		
		<c:forEach items="${map}" var="loc">
			var cctv = new Object();	
			cctv.lon = "${loc.longitude}";
			cctv.lat = "${loc.latitude}";
			positions.push(cctv);				
		</c:forEach>
		
		var i = 527;
		
		function initTmap() {
			
			map = new Tmap.Map({div:'map_div',
				width:'100%',
				height:'850px'
				});
			
			map.setCenter(new Tmap.LonLat("126.979979", "37.564432").transform("EPSG:4326", "EPSG:3857"), 15);
			
			markerLayer = new Tmap.Layer.Markers();
			map.addLayer(markerLayer);
			
			/*
			map.addControls([
				//마우스 커서의 현재 위치가 가지는 좌표값을 맵 위에 표시해 주는 컨트롤
				//좌표값을 WGS84GEO 좌표계의 값으로 표시해줍니다.
		        new Tmap.Control.MousePosition({displayProjection:"EPSG:4326"})
		    ]);
			*/
			
			map.events.register("click", map, onClick);
		}
		
		function onClick(e){
			
			if(count == 0){
				
				console.log("count : "+count);
				
				markerLayer.removeMarker(marker);
				
				console.log((i+2)+"번째");
				
				var size = new Tmap.Size(12, 19); 
				var offset = new Tmap.Pixel(-(size.w / 2), -(size.h));
				
				var cctvmarker = new Tmap.LonLat(positions[i].lon, positions[i].lat).transform("EPSG:4326", "EPSG:3857");
				
				var icon = new Tmap.Icon('http://tmapapis.sktelecom.com/upload/tmap/marker/pin_b_m_a.png',size, offset);
				marker = new Tmap.Marker(cctvmarker, icon);
				markerLayer.addMarker(marker);
				
				map.setCenter(new Tmap.LonLat(positions[i].lon, positions[i].lat).transform("EPSG:4326", "EPSG:3857"), 19);
				
				i = i - 1;
				
				count = count + 1;
				
			}else if(count == 1){
				
				console.log("count : "+count);
				
				var clonlat = map.getLonLatFromViewPortPx(e.xy).transform("EPSG:3857", "EPSG:4326");
				
				var result = clonlat.lon + " " + clonlat.lat;
				
				var resultDiv = document.getElementById("result");
				resultDiv.innerHTML = result;
				
				count = 0;				
			}
			
		}
		
		$(function() {
			initTmap();
		});
	</script>
</head>
<body>
	<div id="map_div"></div>
	<p id="result"></p>
</body>
</html>