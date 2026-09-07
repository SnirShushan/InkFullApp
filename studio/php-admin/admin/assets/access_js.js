
/*function isMatchedAnyArrayValue(a1,a2){
	var isMatched = [];
	
	a1.forEach(function(e1){
		a2.forEach(function(e2){
			if( e1 == e2 ){
				isMatched.push(e1);
			}
		});
	});
	return isMatched;
}*/

function hasAccess(data,acl_name,role_name){
	
    if(role_name == "supper_admin"){ return true; }
    if( data == undefined || data == "" ){
        return false;
    }

    if(acl_name == "" || acl_name == undefined){
    	return false;
    }

    var list = acl_name.split(",");
    var valid = false;

	Object.keys(data).forEach(function(k){
		if( list.includes(k) == true ){
			if(data[k] == true){
				valid = true;
				return;
			}
		}
	});

    return valid;
}

class UserAccess {

	constructor(access) {
		var acl = {};
		var role = "";
		if(access == undefined || access == ""){
			this.access = acl;
			this.role = role;
		}else{
			this.access = access;
			this.role = role;
			if(access.hasOwnProperty("_role")){
				this.role = access['_role'];
			}
		}
	}

	hasAccess( acl_name  ){
		return hasAccess(this.access,acl_name,this.role);
	}

	hasAccessMatched( acl_name  ){
		var me = this;
		var list = acl_name.split(",");
		var isMatched = [];

		Object.keys(me.access).forEach(function(e1){
			list.forEach(function(e2){
				if( e1 == e2 ){
					isMatched.push(e1);
				}
			});
		});
		return isMatched;
	}

	isRole(roleName){
		return (this.role==roleName?true:false);
	}

	isAdmin(){
		return (this.role=="admin"?true:false);
	}

	isSupperAdmin(){
		return (this.role=="supper_admin"?true:false);
	}	

	/*
		{ContainerStart:function(),ContainerEnd:function(),
        
        UserId:0, //optional
        CreateById:0, //optional
        CreateByAdmin:0, //optional

        IsCreateByMe: true,false

        finalized:function(r) return r

		Buttons:[
			{allow_access:'',rander:function()},
			{allow_access:'',rander:function()},
			{allow_access:'',rander:function()},
		]}
	*/
	ActionBarBuilder(config){
		var me = this;

		if( config == "" || config == undefined ){return "";}
		var HTML = "";
		HTML += config.ContainerStart();

	
		if(Array.isArray(config.Buttons)){
			config.Buttons.forEach(function(e){
				var has = me.hasAccess(e.allow_access);

				if(e.hasOwnProperty('finalized')){
					var matched = me.hasAccessMatched(e.allow_access);
					has = e.finalized(has,matched,me);
				}

				if( has ){
					HTML += e.rander(me.role,me.access);
				}
			});
		}

		HTML += config.ContainerEnd();
		return HTML;
	}

}

function GetACL(acl){
	return new UserAccess(acl);
}