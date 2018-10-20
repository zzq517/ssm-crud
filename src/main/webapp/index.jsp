<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>员工列表</title>
<!-- 
	WEB路径:
		不以/开始的相对路径,找资源,以当前资源的路径为基准,经常容易出错.
		以/开始的相对路径,找资源,以服务器的路径为标准.
 -->
 <%
 	pageContext.setAttribute("APP_PATH",request.getContextPath());
 %>
<!-- 引入jquery -->
<script src="${APP_PATH }/static/js/jquery.min.js" type="text/javascript"></script>
<!-- 引入样式 -->
<link href="${APP_PATH }/static/bootstrap-3.3.7-dist/css/bootstrap.min.css" rel="stylesheet">
<!-- 引入js -->
<script src="${APP_PATH }/static/bootstrap-3.3.7-dist/js/bootstrap.min.js" type="text/javascript"></script>
<script type="text/javascript">
	

	$(function(){

		var totalRecord,currentPage;  //总记录数

		//1.页面加载完成后,直接发送ajax请求,获取到分页数据
		to_page(1);

		//点击新增按钮弹出模态框
		$("#emp_add_modal_btn").click(function(){
			//清除表单数据(表单重置)
			reset_form("#empAddModal form");
			//发送ajax请求,查出部门信息,显示下拉列表
			getDepts("#dept_add_select");

			//弹出模态框
			$("#empAddModal").modal({
				backdrop:"static"
			})
		});

		//绑定删除事件
		$(document).on("click",".delete_btn",function(){
			//1.弹出是否确认删除对话框
			var empName = $(this).parent("tr").find("td:eq(1)").text();
			var empId = $(this).attr("delete-id");
			if(confirm("确认删除"+empName+"吗?")){
				//确认,发送ajax请求删除即可
				$.ajax({
					url:"${APP_PATH}/emp/"+empId,
					type:"DELETE",
					success:function(result){
						//回到本页
						to_page(currentPage);
					}
				})
			}
		});

		//绑定编辑事件
		$(document).on("click",".edit_btn",function(){
			
			getDepts("#empUpdateModal select");
			//1.弹出模态框,并显示部门信息
			//2.查询员工信息

			getEmp($(this).attr("attr-id"));
			//3.把员工的id传递给模态框的更新按钮
			$("#emp_update_btn").attr("edit-id",$(this).attr("attr-id"));
			$("#empUpdateModal").modal({
				backdrop:"static"
			})
		});

		//查询员工信息
		function getEmp(id){
			$.ajax({
				url:"${APP_PATH}/emp/"+id,
				type:"GET",
				success:function(result){
					var empData = result.extend.emp;
					$("#empName_update_static").text(empData.empName);
					$("#email_update_input").val(empData.email);
					$("#empUpdateModal input[name=gender]").val([empData.gender]);
					$("#empUpdateModal select").val([empData.dId]);
				}
			})
		};

		//点击更新,更新员工信息
		$("#emp_update_btn").click(function(){
			//验证邮箱是否合法
			//2.校验邮箱信息
			var email = $("#email_update_input").val();
			var regEmail = /^[a-zA-Z0-9_.-]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.[a-zA-Z0-9]{2,6}$/;
			if(!regEmail.test(email)){
				show_validate_msg("#email_update_input","error","邮箱格式不正确");
				return false;
			}else{
				show_validate_msg("#email_update_input","success","");
			}
		
			//发送ajax请求保存更新的员工数据
			$.ajax({
				url:"${APP_PATH}/emp/"+$(this).attr("edit-id"),
				type:"POST",   //页面使用POST请求,后台会转成PUT或DELETE,也可以使用PUT请求,但需要SpringMVC的过滤器
				data:$("#empUpdateModal form").serialize()+"&_method=PUT",
				success:function(result){
					console.log(result);
					//1.关闭对话框
					$("#empUpdateModal").modal("hide");
					//2.回到本页面
					to_page(currentPage);
				}

			})

		});

		//检查用户名是否可用
		$("#emp_add_input").change(function(){
			var empName = this.value;
			//发送ajax请求校验用户名是否可用
			$.ajax({
				url:"${APP_PATH}/checkuser",
				data:"empName="+empName,
				type:"POST",
				success:function(result){
					//成功
					if(result.code==100){
						show_validate_msg("#emp_add_input","success","用户名可用");
						$("#emp_save_btn").attr("ajax-va","success");
					}else{
						show_validate_msg("#emp_add_input","error",result.extend.va_msg);
						$("#emp_save_btn").attr("ajax-va","error");
					}
				}
			})
		})

		//表单重置
		function reset_form(ele){
			$(ele)[0].reset();
			//清空表单样式
			$(ele).find("*").removeClass("has-error has-success");
			$(ele).find(".help-block").text();
		}

		//校验表单数据
		function validate_add_form(){
			//1.使用正则表达式
			var empName = $("#emp_add_input").val();
			var regName = /(^[a-zA-Z0-9]{6,16}$)|(^[\u2E80-\u9FFF]{2,5})/;

			if(!regName.test(empName)){
				show_validate_msg("#emp_add_input","error","用户名可以是2-5位中文或者6-16位英文和数字的组合");
				return false;
			}else{
				show_validate_msg("#emp_add_input","success","");
			}

			//2.校验邮箱信息
			var email = $("#email_add_input").val();
			var regEmail = /^[a-zA-Z0-9_.-]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.[a-zA-Z0-9]{2,6}$/;
			if(!regEmail.test(email)){
				show_validate_msg("#email_add_input","error","邮箱格式不正确");
				
				return false;
			}else{
				show_validate_msg("#email_add_input","success","");
			}

			return true;
		}

		function show_validate_msg(ele,status,msg){
			//清除当前元素的校验状态
			$(ele).parent().removeClass("has-success has-error");
			$(ele).next("span").text("");

			if(status == "success"){
				$(ele).parent().addClass("has-success");
				$(ele).next("span").text(msg);
			}else{
				$(ele).parent().addClass("has-error");
				$(ele).next("span").text(msg);
			}
		}

		//完成全选,全不选功能
		$("#check_all").click(function(){
			//attr获取自定义属性的值, prop获取dom原生的属性
			
			$(".check_item").prop("checked",$(this).prop("checked"));
		});

		$(document).on("click",".check_item",function(){
			var flag = $(".check_item:checked").length == $(".check_item").length;
			$("#check_all").prop("checked", flag);
		});

		//点击全部删除,批量删除
		$("#emp_delete_all").click(function(){

			var empNames = "";
			var del_idstr = "";
			$.each($(".check_item:checked"),function(){
				empNames += $(this).parents("tr").find("td:eq(2)").text()+",";
				//组装员工id字符串
				del_idstr += $(this).parents("tr").find("td:eq(1)").text()+"-";
			});

			//去除最后的逗号
			empNames = empNames.substring(0,empNames.leng-1);
			del_idstr = del_idstr.substring(0,del_idstr.length-1);
			if(confirm("确认删除"+empNames+"吗?")){
				//发送ajax请求
				$.ajax({
					url:"${APP_PATH}/emp/"+del_idstr,
					type:"DELETE",
					success:function(result){
						to_page(currentPage);
					}
				})
			}
		});

		//点击保存员工
		$("#emp_save_btn").click(function(){
			//前端先对提交给服务器的数据进行校验
			if(!validate_add_form()){
				return false;
			};

			//判断之前的ajax用户名是否校验成功
			if($(this).attr("ajax-va")=="error"){
				return false;
			}

			//1.模态框中填写的表单数据提交给服务器进行保存
			//2.发送ajax请求保存员工
			
			$.ajax({
				url:"${APP_PATH}/emp",
				type:"POST",
				data: $("#empAddModal form").serialize(), //使用jquery的表单序列化
				success: function(result){
					console.log(result);
					//后端校验
					if(result.code == 100){
						//保存成功:
						//1.关闭模态框
						$("#empAddModal").modal("hide");
						//2.来到最后一页显示数据
						//发送ajax请求显示最后一页的数据
						to_page(totalRecord); //大于总页码的,分页插件会自动返回最后一页
					}else{
						//显示失败信息
						if(undefined != result.extend.errorFields.email){
							show_validate_msg("#email_add_input","error",result.extend.errorFields.email);
						}
						if(undefined != result.extend.errorFields.empName){
							show_validate_msg("#emp_add_input","error",result.extend.errorFields.empName);
						}
					}
					
				}
			})
		})

		//查出所有部门信息并显示在下拉列表中
		function getDepts(ele){
			//清空之前下拉刘表的值
			$(ele).empty();
			$.ajax({
				url:"${APP_PATH}/depts",
				type:"GET",
				success:function(result){
					//显示部门信息在下拉列表中
					
					$.each(result.extend.depts, function(){
						var optionEle = $("<option></option>").append(this.deptName).attr("value",this.deptId);
						optionEle.appendTo(ele);
					});
				}
			})
		}

		function to_page(pn){
				$.ajax({
					url:"${APP_PATH }/emps",
					data:"pn="+pn,
					type:"get",
					success:function(data){
						//1.解析并显示员工信息
						build_emps_table(data);
						//2.解析并显示分页信息
						build_page_info(data);
						//3.解析显示分页条数据
						build_page_nav(data);
						
					}
				});
			}		

		//显示员工数据
		function build_emps_table(data){
				//清空table
				$("#emps_table tbody").empty();
				var emps = data.extend.pageInfo.list;
				$.each(emps,function(index,item){
					var checkBoxTd = $("<td><input type='checkbox' class='check_item'/></td>");
					var empIdTd = $("<td></td>").append(item.empId);
					var empNameTd = $("<td></td>").append(item.empName);
					var gender = $("<td></td>").append(item.gender=='M'?'男':'女');
					var emailTd = $("<td></td>").append(item.email);
					var deptNameTd = $("<td></td>").append(item.department.deptName);
					
					//编辑按钮
					var editBtn = $("<button></button>").addClass("btn btn-success btn-sm edit_btn")
									.append($("<span></span>").addClass("glyphicon glyphicon-pencil")).append("编辑");
					//为编辑按钮添加一个自定义的属性，表示当前员工的id
					editBtn.attr("attr-id",item.empId);

					//删除按钮
					var delBtn = $("<button></button>").addClass("btn btn-danger btn-sm delete_btn")
								.append($("<span></span>").addClass("glyphicon glyphicon-trash")).append("删除");
					//为删除按钮添加一个自定义的属性,表示当前删除员工的id
					delBtn.attr("delete-id",item.empId);

					var btnTd = $("<td></td>").append(editBtn).append(" ").append(delBtn);

					$("<tr></tr>").append(checkBoxTd)
							.append(empIdTd)
							.append(empNameTd)
							.append(gender)
							.append(emailTd)
							.append(deptNameTd)
							.append(btnTd)
							.appendTo("#emps_table tbody");
				})
		}
		
		//解析显示分页信息
		function build_page_info(data){
			$("#page_info_area").empty();
			$("#page_info_area").append("当前"+data.extend.pageInfo.pageNum+"页,总共"+
						data.extend.pageInfo.pages+"页,总共"+
						data.extend.pageInfo.total+"条记录");
			totalRecord = data.extend.pageInfo.total;
			currentPage = data.extend.pageInfo.pageNum;
		}

		//解析显示分页条,并且能跳转
		function build_page_nav(data){
			$("#page_nav_area").empty();
			var ul = $("<ul></ul>").addClass("pagination");

			var firstPageLi = $("<li></li>").append($("<a></a>").append("首页")).attr("href","#");
			var lastPageLi = $("<li></li>").append($("<a></a>").append("尾页")).attr("href","#");
			var prePageLi = $("<li></li>").append($("<a></a>").append("&laquo;"));
			var nextPageLi = $("<li></li>").append($("<a></a>").append("&raquo;"));

			if(data.extend.pageInfo.hasPreviousPage == false){
				firstPageLi.addClass("disabled");
				prePageLi.addClass("disabled");
			}else{
				//为元素添加点击翻页的事件
				firstPageLi.click(function(){
					to_page(1);
				});
				prePageLi.click(function(){
					to_page(data.extend.pageInfo.pageNum-1);
				})
			}
			if(data.extend.pageInfo.hasNextPage == false){
				nextPageLi.addClass("disabled");
				lastPageLi.addClass("disabled");
			}else{
				//为元素添加点击翻页的事件
				lastPageLi.click(function(){
				to_page(data.extend.pageInfo.pages);
				});
				nextPageLi.click(function(){
					to_page(data.extend.pageInfo.pageNum+1);
				})
			}

			
			

			//添加首页和前一页
			ul.append(firstPageLi).append(prePageLi);

			$.each(data.extend.pageInfo.navigatepageNums, function(index,item){

				var numLi = $("<li></li>").append($("<a></a>").append(item));
				if(data.extend.pageInfo.pageNum == item){
					numLi.addClass("active")
				}
				//跳转
				numLi.click(function(){
					to_page(item);
				})
				ul.append(numLi);
			})
			//添加尾页和后一页
			ul.append(nextPageLi).append(lastPageLi);

			var navEle = $("<nav></nav>").append(ul);

			navEle.appendTo("#page_nav_area");
	}
		
	})


</script>
</head>
<body>
	<!-- 搭建显示页面 -->
	<div class="container">
		<!-- 标题  -->
		<div class="row">
			<div class="col-md-12">
				<h1>SSM-CRUD</h1>
			</div>
		</div>
		<!-- 按钮  -->
		<div class="row">
			<div class="col-md-4 col-md-offset-8">
				<button class="btn btn-success" id="emp_add_modal_btn">新增</button>
				<button class="btn btn-danger" id="emp_delete_all">删除</button>
			</div>
		</div>
		<!-- 表格数据  -->
		<div class="row">
			<div class="col-md-12">
				<table class="table table-hover" id="emps_table">
					<thead>
						<tr>
							<th>
								<input type="checkbox" id="check_all" />
							</th>
							<th>#</th>
							<th>empName</th>
							<th>gender</th>
							<th>email</th>
							<th>depName</th>
							<th>操作</th>
						</tr>
					</thead>
					<tbody>
						
					</tbody>

				</table>
			</div>
		</div>
		<!-- 显示分页信息  -->
		<div class="row">
			<!-- 分页文字信息 -->
			<div class="col-md-6" id="page_info_area"> 
				
			</div>
			<!-- 分页条信息 -->
			<div class="col-md-6" id="page_nav_area">
				
			</div>
		</div>
	</div>

	<!-- 员工添加的模态框 -->
	<div class="modal fade" id="empAddModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
	  	<div class="modal-dialog" role="document">
	    	<div class="modal-content">
		      	<div class="modal-header">
		       		<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
		       		<h4 class="modal-title" id="myModalLabel">员工添加</h4>
	     	 	</div>
		        <div class="modal-body">
		            <form class="form-horizontal">
					    <div class="form-group">
						    <label for="emp_add_input" class="col-sm-2 control-label">EmpName</label>
						    <div class="col-sm-7">
						      	<input type="text" name="empName" class="form-control" id="emp_add_input" placeholder="empName">
						      	<span  class="help-block"></span>
						    </div>
					    </div>
						<div class="form-group">
						    <label for="email_add_input" class="col-sm-2 control-label">Email</label>
						    <div class="col-sm-7">
						      <input type="text" name="email" class="form-control" id="email_add_input" placeholder="email">
						      <span  class="help-block"></span>
						    </div>
						</div>
					    <div class="form-group">
					    	<label for="email_add_input" class="col-sm-2 control-label">Gender</label>
					    	<div class="col-sm-7">
						       	<label class="radio-inline">
								  <input type="radio" name="gender" id="gender1_add_input" value="M" checked="checked"> 男
								</label>
								<label class="radio-inline">
								  <input type="radio" name="gender" id="gender2_add_input" value="F"> 女
								</label>
							</div>
					    </div>
					    <div class="form-group">
					    	<label for="email_add_input" class="col-sm-2 control-label">deptName</label>
					    	<div class="col-sm-4">						
						    	<!--部门提交 -->
						       	<select class="form-control" name="dId" id="dept_add_select">
								   
								</select>
							</div>
					    </div>
					</form>
		      </div>
		      <div class="modal-footer">
		      		<button type="button" id="emp_save_btn" class="btn btn-primary">保存</button>
		        	<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
		      </div>
	        </div>
	    </div>
	</div>

	<!-- 员工修改的模态框 -->
	<div class="modal fade" id="empUpdateModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
	  	<div class="modal-dialog" role="document">
	    	<div class="modal-content">
		      	<div class="modal-header">
		       		<button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
		       		<h4 class="modal-title" >员工修改</h4>
	     	 	</div>
		        <div class="modal-body">
		            <form class="form-horizontal">
					    <div class="form-group">
						    <label for="emp_add_input" class="col-sm-2 control-label">EmpName</label>
						    <div class="col-sm-7">
						      	<p class="form-control-static" id="empName_update_static"></p>
						      	<span  class="help-block"></span>
						    </div>
					    </div>
						<div class="form-group">
						    <label for="email_add_input" class="col-sm-2 control-label">Email</label>
						    <div class="col-sm-7">
						      <input type="text" name="email" class="form-control" id="email_update_input" placeholder="email">
						      <span  class="help-block"></span>
						    </div>
						</div>
					    <div class="form-group">
					    	<label for="email_add_input" class="col-sm-2 control-label">Gender</label>
					    	<div class="col-sm-7">
						       	<label class="radio-inline">
								  <input type="radio" name="gender" id="gender1_update_input" value="M" checked="checked"> 男
								</label>
								<label class="radio-inline">
								  <input type="radio" name="gender" id="gender2_update_input" value="F"> 女
								</label>
							</div>
					    </div>
					    <div class="form-group">
					    	<label for="email_add_input" class="col-sm-2 control-label">deptName</label>
					    	<div class="col-sm-4">						
						    	<!--部门提交 -->
						       	<select class="form-control" name="dId">
								   
								</select>
							</div>
					    </div>
					</form>
		      </div>
		      <div class="modal-footer">
		      		<button type="button" id="emp_update_btn" class="btn btn-primary">更新</button>
		        	<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
		      </div>
	        </div>
	    </div>
	</div>
	
</body>
</html>