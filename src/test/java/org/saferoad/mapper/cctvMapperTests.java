package org.saferoad.mapper;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import lombok.Setter;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration("file:src/main/webapp/WEB-INF/spring/root-context.xml")
public class cctvMapperTests {
	
	@Setter(onMethod_ = @Autowired)
	private cctvMapper mapper;
	
	@Test
	public void testGetLoc() {
		mapper.getLoc();
	}
}
