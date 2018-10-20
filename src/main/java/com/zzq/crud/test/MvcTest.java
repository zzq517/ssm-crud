package com.zzq.crud.test;

import java.util.List;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import com.github.pagehelper.PageInfo;
import com.zzq.crud.bean.Employee;

/**
 * 使用Spring测试模块,测试crud的请求
 * Spring4测试时,需要servlet3.0的支持
 * 
 * @author Administrator
 *
 */
@RunWith(SpringJUnit4ClassRunner.class)
@WebAppConfiguration
@ContextConfiguration(locations= {"classpath:applicationContext.xml","file:src/main/webapp/WEB-INF/dispatcherServlet-servlet.xml"})
public class MvcTest {
	
	//传入SpringMVC的ioc
	@Autowired
	WebApplicationContext context;
	//虚拟mvc请求,获取到处理结果
	MockMvc mockMvc;
	
	//使用之前先执行该方法
	@Before
	public void initMokMvc() {
		mockMvc = MockMvcBuilders.webAppContextSetup(context).build();
	}
	
	@Test
	public void testPage() throws Exception {
		//模拟请求拿到返回值
		MvcResult result = mockMvc.perform(MockMvcRequestBuilders.get("/emps").param("pn", "5"))
		.andReturn();
		
		//请求成功后,请求域中有pageInfo: 可以取出验证
		MockHttpServletRequest request = result.getRequest();
		PageInfo page = (PageInfo) request.getAttribute("pageInfo");
		System.out.println("当前页码:"+page.getPageNum());
		System.out.println("总页码:"+page.getPages());
		System.out.println("总记录数:"+page.getTotal());
		int [] nums = page.getNavigatepageNums();
		for(int i:nums) {
			System.out.println("连续显示的页码:"+i);
		}
		
		//获取员工数据
		List<Employee> list = page.getList();
		for(Employee employee : list) {
			System.out.println("ID:"+employee.getEmpId()+" Name:"+
					employee.getEmpName());
		}
	}
}
