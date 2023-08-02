const mongoose=require("mongoose");
const {productSchema}=require('./product'); 

const userSchema=mongoose.Schema({
    name:{
        type:String,
        required:true,
        trim:true
    },
    email:{
        required:true,
        type:String,
        trim:true,
        validate: {
            validator:(value)=>{
                const re =/^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|.(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                return value.match(re);
            },
            // if email is not valid
            message:"please enter valid email", 
        },
        
    },
    password:{
        require:true,
        type:String,
        validate: {
            validator:(value)=>{
                return value.length>6;
            },
            // if password is less then 6
            message:"please enter long password", 
        },

    },
    address:{
        type:String,
        default:'',
        // required:true,

    },
    type:{
        type:String,
        default:'user',
    },
    // cart 
    cart:[
        {
            product:productSchema, 
            quantity:{
                type:Number,
                required:true,   
            }
        }
    ],
    deviceToken:{
        type:String,
        default:'',
    }
})
// creating user model using mongoose
const User=mongoose.model("User",userSchema);
module.exports=User;