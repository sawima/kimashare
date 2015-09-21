// Meteor.startup(function () {
// 	T9n.setLanguage("zh_cn");
// });
TabularTables = {};

Meteor.isClient && Template.registerHelper('TabularTables', TabularTables);

TabularTables.Users = new Tabular.Table({
  name: "UserList",
  collection: Meteor.users,
  order:[[1,'asc']],
  columns: [
    // {data: "username", title: "User Name"},
    {
    	data: "emails[0].address", 
    	title: "Email"
    	// render:function(val,type,doc) {
    	// 	return val[0].address;
    	// }
    },
    // {
    //   data: "createAt",
    //   title: "Create At",
    //   render: function (val, type, doc) {
    //     if (val instanceof Date) {
    //       return moment(val).calendar();
    //     }
    //   }
    // },
    {
    	data:"profile.fullname",title:"Full Name"
    },
    {data:"profile.phone",title:"Phone"},
    {data:"profile.company",title:"Company"},
    {data:"profile.active",title:"Enabled"},
    // {
    //   data:"roles",
    //   title:"Roles"
    // },
    {
	  tmpl: Meteor.isClient && Template.userActionCell
    }
  ]
});


// TabularTables.Items = new Tabular.Table({
//   name: "ItemList",
//   collection: Articles,
//   order:[[3,'desc']],
//   columns: [
//     {data: "title", title: "Title"},
//     {
//         data: "author.fullname", 
//         title: "Owner"
//     },
//     // {
//     //     data: "receivers[].fullname", 
//     //     title: "Receivers"
//     //     // render:function(val,type,doc) {
//     //     //     // return val.fullname;
//     //     //     receivers=[];
//     //     //     val.forEach(function(element, index){
//     //     //         receivers.push(element.fullname);
//     //     //     });
//     //     //     return receivers.join();
//     //     // }
//     // },
//     {
//       data: "createdAt",
//       title: "Created At",
//       render: function (val, type, doc) {
//         if (val instanceof Date) {
//           // return moment(val).format('MMMM Do YYYY');
//           return val.toDateString();
//         }
//       }
//     },
//     {
//       tmpl: Meteor.isClient && Template.ItemActionCell
//     }
//   ]
// });

// TabularTables.ArchivedItems = new Tabular.Table({
//   name: "ArchivedItemList",
//   collection: Articles,
//   order:[[3,'desc']],
//   columns: [
//     {data: "title", title: "Title"},
//     {
//         data: "author.fullname", 
//         title: "Owner"
//     },
//     {
//         data: "receivers[].fullname", 
//         title: "Receivers"
//         // render:function(val,type,doc) {
//         //     // return val.fullname;
//         //     receivers=[];
//         //     val.forEach(function(element, index){
//         //         receivers.push(element.fullname);
//         //     });
//         //     return receivers.join();
//         // }
//     },
//     {
//       data: "createdAt",
//       title: "Created At",
//       render: function (val, type, doc) {
//         if (val instanceof Date) {
//           // return moment(val).format('MMMM Do YYYY');
//           return val.toDateString();
//         }
//       }
//     },
//     {
//       tmpl: Meteor.isClient && Template.ItemDeleteCell
//     }
//   ]
// });


TabularTables.CZones = new Tabular.Table({
  name: "CollaborationZonesList",
  collection: CollaborationZones,
  order:[[1,'asc']],
  columns: [
    {data: "name", title: "Zone Name"},
    {
        data: "description", 
        title: "Introduce",
        render:function(val,type,doc) {
          if(val!=null || val!=undefined)
            if(val.length<=80)
              return val;
            else
              return val.slice(0,80)+"...";
          else
            return null;
        }
    },
    {data:"isRemoved",title:"Disabled"},
    {
      tmpl: Meteor.isClient && Template.CZoneCtlCell
    }
  ]
});