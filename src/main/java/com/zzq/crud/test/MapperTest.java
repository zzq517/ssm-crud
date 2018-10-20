package com.zzq.crud.test;

import java.util.UUID;

import org.apache.ibatis.session.SqlSession;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.zzq.crud.bean.Department;
import com.zzq.crud.bean.Employee;
import com.zzq.crud.dao.DepartmentMapper;
import com.zzq.crud.dao.EmployeeMapper;

/**
 * 测试Dao层
 * 
 * @author Administrator
 *
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations={"classpath:applicationContext.xml"})
public class MapperTest {
	
	@Autowired
	DepartmentMapper departmentMapper;
	
	@Autowired
	EmployeeMapper employeeMapper;
	
	@Autowired
	SqlSession sqlSession;
	
	/**
	 * 测试DepartmentMapper
	 */
	@Test
	public void testCRUD() {
		/*
		//1创建SpringIOC容器
		ApplicationContext ioc = new ClassPathXmlApplicationContext("applicationContext.xml");
		//2.从容器中获取mapper
		DepartmentMapper bean = ioc.getBean(DepartmentMapper.class);
		*/
		
		//推荐使用Spring的单元测试,可以自动注入需要的组件
		/*
		 * 1.导入SpringTest模块所需的包
		 * 2.@ContextConfiguration指定Spring配置文件的位置
		 * 3.直接autowired要使用的组件即可
		 * */
		
		System.out.println(departmentMapper);
		
		//插入部门
//		departmentMapper.insertSelective(new Department(null,"开发部"));
//		departmentMapper.insertSelective(new Department(null,"测试部"));
		
		//生成员工数据
//		employeeMapper.insertSelective(new Employee(null,"jerry","M","123123@qq.com",1));
//		employeeMapper.insertSelective(new Employee(null,"kore","","123@qq.com",2));
		
		//批量插入多个员工,可以执行批量操作的sqlSession
		EmployeeMapper mapper = sqlSession.getMapper(EmployeeMapper.class);
		for(int i=0; i<1000; ++i) {
			String uid = UUID.randomUUID().toString().substring(0, 5)+i;
			mapper.insertSelective(new Employee(null,uid,"M",uid+"@atguigu.com",1));
		}
	}
	
}

