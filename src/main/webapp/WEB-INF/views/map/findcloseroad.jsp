<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>Insert title here</title>
	<script src="https://api2.sktelecom.com/tmap/js?version=1&format=javascript&appKey=e5e6c714-9b68-48fe-9ff8-46d3dcc0e411"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>					
	<script type="text/javascript">
		var map;
		
		function initTmap(){
			//1. 지도 띄우기
			map = new Tmap.Map({
				div : 'map_div',
				width : "100%",
				height : "850px",
			});
			
			map.setCenter(new Tmap.LonLat("126.986072", "37.570028").transform("EPSG:4326", "EPSG:3857"), 15);
			
			map.events.register("click", map, onClick);
		}
		
		var clonlat, vectorLayer;
		
		function onClick(e){
			
			clonlat = map.getLonLatFromViewPortPx(e.xy).transform("EPSG:3857", "EPSG:4326"); //클릭 부분의 ViewPortPx를 LonLat 좌표로 변환합니다.
			
			vectorLayer = new Tmap.Layer.Vector('TmapVectorLayer'); // 라인을 그릴 벡터 레이어를 생성합니다.
			map.addLayers([vectorLayer]); // map에 레이어를 추가합니다.
			
			var markerStartLayer = new Tmap.Layer.Markers("marker"); // 마커를 찍을 마커 레이어를 생성합니다.
			map.addLayer(markerStartLayer); // map에 레이어를 추가합니다.
			
			// 2. 요청 좌표 마커 찍기
		   	var size = new Tmap.Size(24, 38);
			var offset = new Tmap.Pixel(-(size.w / 2), -size.h);
			var icon = new Tmap.IconHtml("<img src='http://tmapapis.sktelecom.com/upload/tmap/marker/pin_b_m_a.png' />", size, offset);
			var marker_s = new Tmap.Marker(new Tmap.LonLat(clonlat.lon, clonlat.lat).transform("EPSG:4326", "EPSG:3857"), icon);
			markerStartLayer.addMarker(marker_s);
			
			//map.setCenter(new Tmap.LonLat(clonlat.lon, clonlat.lat).transform("EPSG:4326", "EPSG:3857"), 15);
			
			// 3. API 사용요청
			$.ajax({
				method:"GET",
				url:"https://apis.openapi.sk.com/tmap/road/nearToRoad?version=1", // 가까운 도로 찾기 api 요청 url입니다.
				async:false,
				data:{
					"lon" : clonlat.lon,
					"lat" : clonlat.lat,
					"appKey" : "e5e6c714-9b68-48fe-9ff8-46d3dcc0e411", // 실행을 위한 키 입니다. 발급받으신 AppKey(서버키)를 입력하세요.
				},
				success:function(response){
			    	prtcl = response;
					
					if(prtcl.resultData.header){
						var tDistance = "총 거리 : "+prtcl.resultData.header.totalDistance+"m,";
						var tTime = " 제한 속도 : "+prtcl.resultData.header.speed+"km/H,";	
						var rName = " 도로명 : "+prtcl.resultData.header.roadName+", ";
				    	var linkId = " linkId : "+prtcl.resultData.header.linkId+prtcl.resultData.header.idxName;
		
				    	$("#result").text(tDistance+tTime+rName+linkId);
					}else{
						$("#result").text("가까운 도로 검색 결과가 없습니다.");
					}
					
					var linkPoints = prtcl.resultData.linkPoints;
					var pointList = [];	// 선으로 그려질 포인트
					for( var i in linkPoints ) {
						pointList.push(new Tmap.Geometry.Point(linkPoints[i].location.longitude, linkPoints[i].location.latitude).transform("EPSG:4326", "EPSG:3857")); 
					}	// 응답 받은 도로 좌표를 변환하여, 배열에 담아 놓습니다.
					
					var lineString, lineFeature;
					var lineStyle = {
							strokeWidth: 6,
							strokeColor: '#FF0000'
					};	// 라인의 스타일 입니다.
					
					lineString = new Tmap.Geometry.LineString(pointList); // 라인 스트링 생성
					lineFeature = new Tmap.Feature.Vector(lineString, null, lineStyle); // 백터 생성
					vectorLayer.addFeatures([lineFeature]); // 백터를 백터 레이어에 추가
				},
				error:function(request,status,error){
					console.log("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
				}
			});
			
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