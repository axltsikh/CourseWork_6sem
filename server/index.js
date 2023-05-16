const express = require('express');
const app = express();
const sql = require('mssql');
app.use(express.json())
app.listen(5000)
const sqlConfig ={
    server: 'DESKTOP-1L560B9',
    database: 'CourseWorkDatabase',
    authentication: {
        type: "default",
        options: {
            userName: "axl",
            password: "12345678"
       }
    },
    port: 1433,
    options:{
        trustServerCertificate: true,
    }
}
let open = async()=>{
    await sql.connect(sqlConfig)
}
open();
app.use(function(req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Methods", "GET,PUT,PATCH,POST,DELETE");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
});
app.post("/user/create",function(req,response){
    const request = new sql.Request();
    let buffer = JSON.parse(JSON.stringify(req.body));
    request.input('name',buffer.name)
    request.input('password',buffer.password)
    request.execute('CreateUser',(err,result)=>{
        if(result.returnValue==1){
            response.statusCode=200
            response.end("Пользователь успешно создан");
        }else{
            response.statusCode=500
            response.end("Имя пользователя занято!");
        }
    })
})
app.post("/user/login",function(req,response){
    console.log("Login call");
    const request = new sql.Request();
    let buffer = JSON.parse(JSON.stringify(req.body));
    request.input('name',buffer.name)
    request.execute('Login',(err,result)=>{
        if(result.recordsets[0].length==0){
            response.statusCode = 404;
            response.end("Пользователь не существует");
        }
        else{
            let passwordBuffer = JSON.parse(JSON.stringify(result.recordset.at(0))).password;
            let id = JSON.parse(JSON.stringify(result.recordset.at(0))).id;
        if(buffer.password==passwordBuffer){
            response.statusCode = 200;
            response.end(id.toString());
        }else{
            response.statusCode=500;
            response.end("Неверный пароль!");
        }
        }
    })
})
app.post("/user/changePassword",function(req,response){
    console.log("ChangePassword request");
    const request = new sql.Request();
    let buffer = JSON.parse(JSON.stringify(req.body));
    request.input('id',buffer.id)
    request.input('password',buffer.password)
    console.log(buffer.password);
    console.log(buffer.id);
    request.execute('ChangePassword',(err,result)=>{
        if(result.returnValue==1){
            console.log("change succes");
            response.statusCode =200;
            response.end("Пароль успешно изменен")
        }else{
            response.statusCode = 404;
            response.end("Пользователь не сущствует")
        }
    })
})
app.get("/profile/getUserOrganisation",function(req,response){
    const request = new sql.Request();
    request.input('userID',req.query.id)
    request.execute('getUserOrganisation',(err,result)=>{
        if(result.recordsets[0].length==0){
            response.statusCode = 404;
            response.end("Организация не найдена");
        }else{
            response.statusCode = 200;
            response.end(JSON.stringify(result.recordset.at(0)));
        }
    })
})
app.delete("/organisation/leave",function(req,response){
    const request = new sql.Request();
    request.input('userID',req.query.id);
    request.execute('LeaveOrganisation',(err,result)=>{
        response.statusCode=200;
        response.end("Leaved succesfully");
    })
})
app.get("/organisation/getAllOrganisations",function(req,response){
    const request = new sql.Request();
    request.execute("GetAllOrganisations",(err,result)=>{
        response.end(JSON.stringify(result.recordset));
    })
})
app.post("/organisation/joinOrganisation",function(req,response){
    const request = new sql.Request();
    let buffer = JSON.parse(JSON.stringify(req.body));
    request.input('organisationID',buffer.organisationID);
    request.input('userID',buffer.userID);
    request.execute('JoinOrganisation',(err,result)=>{
        console.log(result.rowsAffected);
            console.log(result.output);
        if(result.returnValue==1){
            response.statusCode = 200;
            response.end("Операция успешно выполнена");
        }else{
            console.log(result.rowsAffected);
            console.log(result.output);
            response.statusCode =500;
            response.end("Произошла ошибка");
        }
    })
})
app.post("/organisation/create",function(req,response){
    const request = new sql.Request();
    let buffer = JSON.parse(JSON.stringify(req.body));
    request.input('organisationName',buffer.organisationName);
    request.input('organisationPassword',buffer.organisationPassword);
    request.input('creatorID',buffer.creatorID);
    request.execute('CreateOrganisation',(err,result)=>{
        if(result.returnValue==1){
            console.log("success");
            response.statusCode = 200;
            response.end("Организация успешно создана");
        }else{
            console.log("error")
            response.statusCode =500;
            response.end("Произошла ошибка");
        }
    })
})
app.post("/organisation/getMembers",function(req,response){
    const request = new sql.Request();
    let buffer = JSON.parse(JSON.stringify(req.body));
    request.input('userID',buffer.userID);
    request.execute('GetOrganisationMembers',(err,result)=>{
        try{
            console.log(JSON.stringify(result.recordset));
            response.statusCode = 200;
            response.end(JSON.stringify(result.recordset));
        }
        catch(e){
            response.statusCode = 500
            response.end("Произошла ошибка")
        }
    })
})
app.post("/project/create",function(req,response){
    request = new sql.Request();
    let buffer = JSON.parse(JSON.stringify(req.body));
    request.input('userID',buffer.userID);
    var organisationMemberID = 0;
    request.execute('GetOrganisationMemberIDByUserID',(err,result)=>{
        organisationMemberID = result.recordset[0].id;
        request = new sql.Request();
        request.input('title',buffer.title)
        request.input('description',buffer.description)
        request.input('startDate',buffer.startDate)
        request.input('endDate',buffer.endDate)
        request.input('organisationMemberID',organisationMemberID)
        console.log(organisationMemberID);
        request.execute('CreateProject',(err,result)=>{
        if(result.returnValue==1){
              response.statusCode=200
            response.end("Проект успешно создан")
        }else{
            response.statusCode=500
           response.end("Произошла ошибка")
        }
        })
    })
})
app.post("/project/addMembers",function(req,response){
    let buffer = JSON.parse(JSON.stringify(req.body));
    try{
        buffer.forEach(element => {
            const request = new sql.Request();
            request.input('id',element.organisationID)
            request.execute('AddProjectMember',(err,result)=>{
                if(result.returnValue==-1){
                    response.statusCode=500
                    response.end("Произошла ошибка");
                }
            })
        });
        response.statusCode = 200;
        response.end("Успешно выполнено")        
    }catch{
        console.log(buffer.organisationID);
        const request = new sql.Request();
            request.input('id',buffer.organisationID)
            request.input('projectID',buffer.projectID)
            request.execute('AddExistingProjectMember',(err,result)=>{
                if(result.returnValue==-1){
                    response.statusCode=500
                    response.end("Произошла ошибка");
                }
            })
            response.statusCode = 200;
            response.end("Операция успешна!") 
    }

})


app.get("/project/getAllUserProjects",function(req,response){
    console.log("getAllUserProjects call");
    request = new sql.Request();
    request.input('userID',req.query.userID);
    request.execute('GetAllUserProjects',(err,result)=>{
        response.statusCode=200
        response.end(JSON.stringify(result.recordset));
    })
})
app.put("/organisation/updateName",function(req,response){
    console.log("getAllUserProjects call");
    request = new sql.Request();
    let buffer = JSON.parse(JSON.stringify(req.body));
    request.input('organisationID',buffer.organisationID);
    request.input('newName',buffer.newName);
    request.execute('UpdateOrganisationName',(err,result)=>{
        response.statusCode=200
        response.end(JSON.stringify(result.recordset));
    })
})

app.post("/project/addSubTask",function(req,response){
    console.log("proejcts call");
    request = new sql.Request();
    
    request.input('userID',req.query.userID);
    request.execute('GetAllUserProjects',(err,result)=>{
        response.statusCode=200
        response.end(JSON.stringify(result.recordset));
    })
})


app.get("/project/getAllProjectMembers",function(req,response){
    console.log("proejctsMembers call");
    
    request = new sql.Request();
    request.input('projectID',req.query.projectID);
    request.execute('GetAllProjectMembers',(err,result)=>{
        console.log(JSON.stringify(result.recordset));
        response.statusCode=200
        response.end(JSON.stringify(result.recordset));
    })
})
app.post("/profile/getUserOrganisation",function(req,response){
    console.log("proejcts call");
    request = new sql.Request();
    request.input('userID',req.query.userID);
    request.execute('GetAllUserProjects',(err,result)=>{
        response.statusCode=200
        response.end(JSON.stringify(result.recordset));
    })
})
app.delete("/organisation/removeMember",function(req,response){
    const request = new sql.Request();
    request.input('memberID',req.query.id);
    request.execute('DeleteOrganisationMember',(err,result)=>{
        if(result.returnValue==1){
            response.statusCode=200;
            response.end("Leaved succesfully");
        }else{
            response.statusCode = 500;
            response.end("Произошла ошибка")
        }
    })
})
app.post("/project/addParentSubTask",function(req,response){
    console.log("AddParentTask call");
    let buffer = JSON.parse(JSON.stringify(req.body));
    request = new sql.Request();
    console.log(buffer.projectID);
    request.input('title',buffer.title);
    request.input('projectID',buffer.projectID);
    request.execute('InsertParentSubTask',(err,result)=>{
        if(result.returnValue!=-1){
            response.statusCode=200
            response.end(result.returnValue.toString())
        }else{
            response.statusCode=500
            response.end("Произошла ошибка")
        }
    })
})
app.get("/project/getProjectParentTasks",function(req,response){
    console.log("projectTasks call");
    request = new sql.Request();
    request.input('projectID',req.query.projectID);
    request.execute('GetAllParentTasks',(err,result)=>{
        response.statusCode=200
        response.end(JSON.stringify(result.recordset));
    })
})
app.post("/project/addChildSubTask",function(req,response){
    console.log("AddParentTask call");
    let buffer = JSON.parse(JSON.stringify(req.body));
    request = new sql.Request();
    console.log(buffer.projectID);
    request.input('title',buffer.title);
    request.input('projectID',buffer.projectID);
    request.input('parentID',buffer.parent);
    request.execute('InsertChildSubTask',(err,result)=>{
        if(result.returnValue!=-1){
            response.statusCode=200
            response.end(result.returnValue.toString())
        }else{
            response.statusCode=500
            response.end("Произошла ошибка")
        }
    })
})
app.post("/project/addSubTaskExecutor",function(req,response){
    console.log("addSubTaskExecutor call");
    let buffer = JSON.parse(JSON.stringify(req.body));
    request = new sql.Request();
    console.log(buffer.projectID);
    request.input('subtaskID',req.query.subtaskID);
    request.input('executorID',buffer.id);
    request.execute('InsertSubTaskExecutor',(err,result)=>{
        if(result.returnValue==1){
            response.statusCode=200
            response.end("Успешно")
        }else{
            response.statusCode=500
            response.end("Произошла ошибка")
        }
    })
})
app.get("/project/getProjectChildTasks",function(req,response){
    console.log("getProjectParentTasks call");
    request = new sql.Request();
    request.input('projectID',req.query.projectID);
    request.execute('GetChildSubTasksInfo',(err,result)=>{
        response.statusCode=200
        response.end(JSON.stringify(result.recordset));
    })
})
app.get("/project/getProjectCreatorUserID",function(req,response){
    console.log("getProjectCreatorUserID call");
    request = new sql.Request();
    request.input('projectID',req.query.projectID);
    request.execute('GetProjectCreatorUserID',(err,result)=>{
        response.statusCode=200
        response.end(JSON.stringify(result.recordset));
    })
})
app.post("/project/offerChanges",function(req,response){
    console.log("offerChanges call");
    let buffer = JSON.parse(JSON.stringify(req.body));
    try{
        buffer.forEach(element => {
            const request = new sql.Request();
            request.input('SubTaskID',element.subTaskID)
            request.input('isDone',element.isDone)
            request.execute('OfferChanges',(err,result)=>{
                if(result.returnValue==-1){
                    response.statusCode=500
                    response.end("Произошла ошибка");
                }
            })
        });
        response.statusCode = 200;
        response.end("Операция успешна!")        
    }catch{
        console.log(buffer.organisationID);
        const request = new sql.Request();
        request.input('SubTaskID',element.subtaskID)
        request.input('isDone',element.isDone)
        request.execute('OfferChanges',(err,result)=>{
            if(result.returnValue==-1){
                response.statusCode=500
                response.end("Произошла ошибка");
            }
        })
        response.statusCode = 500;
        response.end("Операция успешна!") 
    }

})
app.post("/project/commitChanges",function(req,response){
    console.log("commitChanges call");
    let buffer = JSON.parse(JSON.stringify(req.body));
    buffer.forEach(element => {
        console.log();
        const request = new sql.Request();
        request.input('SubTaskID',element.subTaskID)
        request.input('isDone',element.isDone)
        request.execute('CommitChanges',(err,result)=>{
            if(result.returnValue==-1){
                response.statusCode=500
                response.end("Произошла ошибка");
            }
        })
    });
    response.statusCode = 200;
    response.end("Операция успешна!")    
})
app.get("/local/getOrganisationMemberRows",function(req,response){
    console.log("getProjectCreatorUserID call");
    request = new sql.Request();
    request.input('organisationID',req.query.id);
    console.log(req.query.id);
    request.execute('SelectOrganisationMemberRows',(err,result)=>{
        response.statusCode=200
        response.end(JSON.stringify(result.recordset));
    })
})
app.get("/local/getProjectMemberRows",function(req,response){
    console.log("getProjectCreatorUserID call");
    request = new sql.Request();
    request.input('userID',req.query.id);
    request.execute('SelectProjectMemberRows',(err,result)=>{
        response.statusCode=200
        response.end(JSON.stringify(result.recordset));
    })
})
app.get("/local/getProjectRows",function(req,response){
    console.log("getProjectRows call");
    request = new sql.Request();
    request.input('userID',req.query.id);
    request.execute('SelectProjectRows',(err,result)=>{
        response.statusCode=200
        response.end(JSON.stringify(result.recordset));
    })
})
app.get("/local/getSubTasksRows",function(req,response){
    console.log("getProjectRows call");
    request = new sql.Request();
    request.input('userID',req.query.id);
    request.execute('SelectSubTasksRows',(err,result)=>{
        response.statusCode=200
        response.end(JSON.stringify(result.recordset));
    })
})
app.get("/local/getSubTasksExecutorRows",function(req,response){
    console.log("getProjectRows call");
    request = new sql.Request();
    request.input('userID',req.query.id);
    request.execute('SelectSubTasksExecutorsRows',(err,result)=>{
        response.statusCode=200
        response.end(JSON.stringify(result.recordset));
    })
})
app.get("/local/getAllOrganisationUsersRows",function(req,response){
    console.log("getProjectCreatorUserID call");
    request = new sql.Request();
    request.input('organisationID',req.query.id);
    request.execute('SelectAllOrganisationUsersRows',(err,result)=>{
        response.statusCode=200
        response.end(JSON.stringify(result.recordset));
    })
})
app.delete("/project/delete",function(req,response){
    console.log("Project delete click");
    const request = new sql.Request();
    let buffer = JSON.parse(JSON.stringify(req.body));
    request.input('projectID',buffer.id);
    request.execute('DeleteProject',(err,result)=>{
        response.statusCode=200;
        response.end("Deleted succesfully");
    })
})


//webApp
app.post("/web/getAllCreatorProjects",function(req,response){
    console.log("getAllCreatorProjects call");
    request = new sql.Request();
    let buffer = JSON.parse(JSON.stringify(req.body));
    request.input('userID',buffer.userID);
    request.execute('getAllCreatorProjects',(err,result)=>{
        response.statusCode=200
        response.end(JSON.stringify(result.recordset));
    })
})
app.post("/web/GetAllChildSubTasks",function(req,response){
    console.log("GetAllChildSubTasks call");
    request = new sql.Request();
    let buffer = JSON.parse(JSON.stringify(req.body));
    request.input('projectID',buffer.projectID);
    request.execute('GetAllChildSubTasks',(err,result)=>{
        response.statusCode=200
        response.end(JSON.stringify(result.recordset));
    })
})
app.post("/web/prolongProjectDate",function(req,response){
    console.log("prolongProjectDate call");
    request = new sql.Request();
    let buffer = JSON.parse(JSON.stringify(req.body));
    request.input('projectID',buffer.projectID);
    request.input('endDate',buffer.endDate);
    console.log(buffer.projectID);
    console.log(buffer.endDate);
    request.execute('ProlongProjectDate',(err,result)=>{
        if(result.returnValue==1){
            response.statusCode=200
            response.end("Успешно выполнено")
        }else{
            response.statusCode = 500;
            response.end("Произошла ошибка");
        }
        
    });
})
app.post("/web/endProject",function(req,response){
    console.log("endProject call");
    request = new sql.Request();
    let buffer = JSON.parse(JSON.stringify(req.body));
    request.input('projectID',buffer.projectID);
    request.execute('EndProject',(err,result)=>{
        if(result.returnValue==1){
            response.statusCode=200
            response.end("Успешно выполнено")
        }else{
            response.statusCode = 500;
            response.end("Произошла ошибка");
        }
        
    });
})
app.delete("/web/deleteMember",function(req,response){


    console.log("deleteMember call");
    request = new sql.Request();
    request.input('id',req.query.id);
    console.log(req.query.id);
    request.execute('deleteMember',(err,result)=>{
        if(result.returnValue==1){
            response.statusCode=200
            response.end("Успешно выполнено")
        }else{
            response.statusCode = 500;
            response.end("Произошла ошибка");
        }
        
    });
})
app.delete("/web/deleteChildSubTask",function(req,response){
    console.log("deleteChildSubTask call");
    request = new sql.Request();
    request.input('id',req.query.id);
    console.log(req.query.id);
    request.execute('DeleteChilSubTask',(err,result)=>{
        if(result.returnValue==1){
            response.statusCode=200
            response.end("Успешно выполнено")
        }else{
            response.statusCode = 500;
            response.end("Произошла ошибка");
        }
        
    });
})
app.delete("/web/deleteParentSubTask",function(req,response){
    console.log("deleteParentSubTask call");
    request = new sql.Request();
    let buffer = JSON.parse(JSON.stringify(req.body));
    request.input('id',req.query.id);
    request.execute('DeleteParentSubTask',(err,result)=>{
        if(result.returnValue==1){
            response.statusCode=200
            response.end("Успешно выполнено")
        }else{
            response.statusCode = 500;
            response.end("Произошла ошибка");
        }
        
    });
})
//reverseSync
app.post("/reverseSync/updateMemberState",function(req,response){
    const request = new sql.Request();
    let buffer = JSON.parse(JSON.stringify(req.body));
    request.input('id',buffer.id)
    if(buffer.deleted == 'true'){
        request.input('deleted',1)
        console.log(1);
    }else{
        request.input('deleted',0)
        console.log(0);
    }
    request.execute('ChangeMemberState',(err,result)=>{
        if(result.returnValue==1){
            response.statusCode =200;
            response.end("Статус изменен")
        }else{
            response.statusCode = 500;
            response.end("Произошла ошибка")
        }
    })
})
app.post("/reverseSync/uploadProject",function(req,response){
    console.log("uploadProject call");
    request = new sql.Request();
    let buffer = JSON.parse(JSON.stringify(req.body));
    request.input('userID',buffer.userID);
    var organisationMemberID = 0;
    request.execute('GetOrganisationMemberIDByUserID',(err,result)=>{
        organisationMemberID = result.recordset.at(0).id;
        console.log('post: ' + result.recordset.at(0).id);

        request = new sql.Request();
        request.input('title',buffer.title)
        request.input('description',buffer.description)
        request.input('startDate',buffer.startDate)
        request.input('endDate',buffer.endDate)
        request.input('organisationMemberID',organisationMemberID)
        console.log(organisationMemberID);
        request.execute('UploadProject',(err,result)=>{
        if(result.returnValue!=0){
            response.statusCode=200
            console.log(result.returnValue.toString());
            response.end(result.returnValue.toString())
        }else{
            response.statusCode=500
           response.end("Произошла ошибка")
        }
        })
    })
})
app.get("/reverseSync/uploadProject",function(req,response){
    console.log("uploadProject call");
    request = new sql.Request();
    request.input("id",req.query.id)
    request.execute('GetProjectCreatorID',(err,result)=>{
        console.log('get: id' + result.recordset.at(0).id);
        response.statusCode=200
        response.end(result.recordset.at(0).id.toString())
    })
})


app.post("/reverseSync/uploadProjectMembers",function(req,response){
    console.log("uploadProjectMembers call");
    let buffer = JSON.parse(JSON.stringify(req.body));
    request = new sql.Request();
    request.input('projectID',buffer.projectID);
    request.input('organisationMemberID',buffer.organisationMemberID);
    console.log("memid: " + buffer.organisationMemberID);
    console.log("projid: " + buffer.projectID);
    request.execute('UploadProjectMember',(err,result)=>{
        if(result.returnValue!=-1){
            response.statusCode=200
            response.end(result.returnValue.toString())
        }else{
            response.statusCode=500
            response.end("Произошла ошибка")
        }
    })
})
app.post("/reverseSync/uploadParentSubTask",function(req,response){
    console.log("AddParentTask call");
    let buffer = JSON.parse(JSON.stringify(req.body));
    request = new sql.Request();
    request.input('title',buffer.title);
    request.input('projectID',buffer.projectID);
    console.log('got projectID: ' + buffer.projectID);
    console.log('got title: ' + buffer.title);
    request.execute('UploadParentSubTask',(err,result)=>{
        if(result.returnValue!=-1){
            response.statusCode=200
            console.log('uploaded parent: ' + result.returnValue.toString());
            response.end(result.returnValue.toString())
        }else{
            response.statusCode=500
            response.end("Произошла ошибка")
        }
    })
})
app.post("/reverseSync/uploadChildSubTask",function(req,response){
    console.log("uploadChildSubTask call");
    let buffer = JSON.parse(JSON.stringify(req.body));
    request = new sql.Request();
    request.input('title',buffer.title);
    request.input('projectID',buffer.projectID);
    request.input('parentID',buffer.parent);
    request.input('isDone',buffer.isDone);
    request.input('isTotallyDone',buffer.isTotallyDone);
    request.input('ExecutorID',buffer.executorID);
    request.input('executorMemberID',buffer.executorMemberID);
    console.log('got parentID: ' + buffer.parent);
    console.log('got title: ' + buffer.title);
    request.execute('UploadChildSubTask',(err,result)=>{
        if(result.returnValue!=-1){
            response.statusCode=200
            console.log('got response: ' + result.returnValue.toString());
            response.end(result.returnValue.toString())
        }else{
            response.statusCode=500
            response.end("Произошла ошибка")
        }
    })
})
app.post("/reverseSync/uploadSimplyChangedChildSubTask",function(req,response){
    console.log("uploadSimplyChangedChildSubTask call");
    let buffer = JSON.parse(JSON.stringify(req.body));
    request = new sql.Request();
    request.input('id',buffer.id);
    request.input('isDone',buffer.isDone);
    request.input('isTotallyDone',buffer.isTotallyDone);
    request.execute('UploadSimplyChangedSubTask',(err,result)=>{
        if(result.returnValue!=-1){
            response.statusCode=200
            response.end(result.returnValue.toString())
        }else{
            response.statusCode=500
            response.end("Произошла ошибка")
        }
    })
})