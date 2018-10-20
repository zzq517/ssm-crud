package com.zzq.crud.controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.zzq.crud.bean.Employee;
import com.zzq.crud.bean.Msg;
import com.zzq.crud.service.EmployeeService;

/**
 * 处理员工CRUD请求
 * @author Administrator
 *
 */
//控制器
@Controller
public class EmployeeController {
	
	//自动装配
	@Autowired
	EmployeeService employeeService;
	
	/*
	 	使用Rest风格
	 	GET（SELECT）：从服务器查询，可以在服务器通过请求的参数区分查询的方式。  
		POST（CREATE）：在服务器新建一个资源，调用insert操作。  
		PUT（UPDATE）：在服务器更新资源，调用update操作。  
		DELETE（DELETE）：从服务器删除资源，调用delete语句
		
		URI
		/emp/{id}  GET  查询员工
		/emp 	   POST 保存员工
		/emp/{id}  PUT  修改员工
		/emp/{id}  DELETE 删除员工
	*/
	
	
	/**
	 * 
	 * 单个和批量删除
	 * 批量  1-2-3
	 * 单个  1
	 * @param id
	 * @return
	 */
	@RequestMapping(value="/emp/{id}", method=RequestMethod.DELETE)
	@ResponseBody
	public Msg deleteEmp(@PathVariable("id") String ids){
		//批量删除
		if(ids.contains("-")){
			List<Integer> del_ids = new ArrayList<>();
			String []str_ids = ids.split("-");
			//组装id的集合
			for(String string : str_ids){
				del_ids.add(Integer.parseInt(string));
			}
			employeeService.deleteBatch(del_ids);
		}else{
			Integer id = Integer.parseInt(ids);
			employeeService.deleteEmp(id);
		}
		
		return Msg.success();
	}
	
	/**
	 *  AJAX发送PUT请求引发的问题:
	 * 	PUT请求体中的数据,Tomcat的request.getParameter()无法
	 *  拿到,只有POST或者GET格式的请求才可以封装为map
	 * 
	 * 	AJAX直接发送PUT请求需要配上HttpPutFormContentFilter
	 * 	作用:将请求提中的数据解析包装成一个map,request被重新包装,
	 *  request.getParameter()被重写,就会从自己封装的map中获取数据
	 * 
	 * 员工更新方法
	 * @param employee
	 * @return
	 */
	@RequestMapping(value="/emp/{empId}",method=RequestMethod.PUT)
	@ResponseBody
	public Msg updateEmp(Employee employee) {
		
		employeeService.updateEmp(employee);
		return Msg.success();
	}
	
	@RequestMapping(value="/emp/{id}",method=RequestMethod.GET)
	@ResponseBody
	public Msg getEmp(@PathVariable("id") Integer id) {
		
		Employee employee = employeeService.getEmp(id);
		
		return Msg.success().add("emp", employee);
	}
	
	@RequestMapping("/checkuser")
	@ResponseBody
	public Msg checkUser(@RequestParam("empName")String empName){
		//先判断用户名是否是合法的表达式
		String regx = "(^[a-zA-Z0-9]{6,16}$)|(^[\u2E80-\u9FFF]{2,5})";
		if(!empName.matches(regx)){
			return Msg.fail().add("va_msg","用户名必须是6-16位数字和字母的组合或者2-5位中文");
		}
		
		//数据库用户名重复校验
		boolean b = employeeService.checkUser(empName);
		if(b)
			return Msg.success();
		else
			return Msg.fail().add("va_msg", "用户名不可用");
	}
	
	/**
	 * 员工保存
	 * 1.支持JSR303校验
	 * 2.导入Hibernate-Validator
	 * 
	 * @param employee
	 * @return
	 */
	@RequestMapping(value="/emp", method=RequestMethod.POST)
	@ResponseBody
	public Msg saveEmp(@Valid Employee employee, BindingResult result) {
		if(result.hasErrors()){
			//校验失败,返回失败
			Map<String,Object> map = new HashMap<String, Object>();
			List<FieldError> fieldErrors = result.getFieldErrors();
			for(FieldError errors: fieldErrors){
				System.out.println("错误字段名"+errors.getField());
				System.out.println("错误信息:"+errors.getDefaultMessage());
				map.put(errors.getField(), errors.getDefaultMessage());
			}
			return Msg.fail().add("errorFields", map);
		}else{
			employeeService.saveEmp(employee);
			return Msg.success();
		}
	}
	
	/**
	 * 需要导入jackson包,@ResponseBoydy才可以使用
	 * @param pn
	 * @return
	 */
	//使用JSON的方式改写getEmps方法,使之可以用在AJAX上
	@RequestMapping("/emps")
	@ResponseBody
	public Msg getEmpsWithJson(@RequestParam(value="pn", defaultValue="1") Integer pn){
		//引入pagehelper插件,在查询前只需调用startPage(页码,每页数量)
		PageHelper.startPage(pn,5);
		//startPage后紧跟的一个查询就是分页查询
		List<Employee> emps = employeeService.getAll();
		
		//使用PageInfo包装查询后的结果,只需将pageInfo交给页面就行
		//封装了详细的分页信息,包括查询出来的数据(5代表连续显示的页数)
		PageInfo page = new PageInfo(emps,5);
		
		return Msg.success().add("pageInfo", page);
	}
	
	/**
	 * 查询员工数据(分页查询)
	 * @return
	 */
	/*
	@RequestMapping("/emps")
	public String getEmps(@RequestParam(value="pn",defaultValue="1") Integer pn, 
			Model model) {
		
		//引入pagehelper插件,在查询前只需调用startPage(页码,每页数量)
		PageHelper.startPage(pn,5);
		//startPage后紧跟的一个查询就是分页查询
		List<Employee> emps = employeeService.getAll();
		
		//使用PageInfo包装查询后的结果,只需将pageInfo交给页面就行
		//封装了详细的分页信息,包括查询出来的数据(5代表连续显示的页数)
		PageInfo page = new PageInfo(emps,5);
		model.addAttribute("pageInfo",page);
		
		return "list";
	}
	*/
}
