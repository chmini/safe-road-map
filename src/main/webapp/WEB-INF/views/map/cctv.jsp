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
		var map,marker,markerLayer;
		var markerArray = new Array();
		var vector_layer = new Tmap.Layer.Vector('Tmap Vector Layer');
   		
		function initTmap(){
			// map 생성
			// Tmap.map을 이용하여, 지도가 들어갈 div, 넓이, 높이를 설정합니다.
			map = new Tmap.Map({div:'map_div', // map을 표시해줄 div
								width:'100%',  // map의 width 설정
								height:'850px' // map의 height 설정
								});
			
			map.setCenter(new Tmap.LonLat("126.979979", "37.564432").transform("EPSG:4326", "EPSG:3857"), 15);
			
			map.events.register("click", map, onClick);
		}
		
		function onClick(e) {
			
			markerLayer = new Tmap.Layer.Markers(); //마커 레이어 생성
			map.addLayer(markerLayer); //map에 마커 레이어 추가
	   		
	   		var size = new Tmap.Size(12, 19); //아이콘 크기
			var offset = new Tmap.Pixel(-(size.w / 2), -(size.h));
			
			var positions = new Array();			
			
			<c:forEach items="${map}" var="loc">
				var cctv = new Object();	
				cctv.lon = "${loc.longitude}";
				cctv.lat = "${loc.latitude}";
				positions.push(cctv);				
			</c:forEach>
			
			//console.log(positions[0].lon);
			
			var lonlat = new Array();
			
			for(var i=0; i<positions.length; i++){
				lonlat[i] = new Tmap.LonLat(positions[i].lon, positions[i].lat).transform("EPSG:4326", "EPSG:3857");
			}
			
			for(var i=0; i<positions.length; i++){ //for문을 통하여 배열 안에 있는 값을 마커 생성
				var icon = new Tmap.Icon('http://tmapapis.sktelecom.com/upload/tmap/marker/pin_b_m_a.png',size, offset); //아이콘 설정
				marker = new Tmap.Marker(lonlat[i], icon); //마커 생성
				markerArray.push(marker);
				markerLayer.addMarker(marker); //마커 레이어에 마커 추가
			
			}
			
		}
	
		$(function () {
			initTmap();
    	});
	</script> 
</head>
<body>
	<div id="map_div">
	
	</div>
</body>
</html>