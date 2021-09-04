package org.saferoad.service;

import java.util.List;

import org.saferoad.domain.cctvVO;
import org.saferoad.mapper.cctvMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import lombok.Setter;

@Service
public class cctvServiceImpl implements cctvService{
	
	@Setter(onMethod_ = @Autowired)
	private cctvMapper mapper;

	@Override
	public List<cctvVO> getLoc() {
		// TODO Auto-generated method stub
		return mapper.getLoc();
	}

	@Override
	public List<cctvVO> getLoc2() {
		// TODO Auto-generated method stub
		return mapper.getLoc2();
	}
	
}
