// import from pakages
const express=require("express");
const User = require("../models/user");
const bcryptjs=require("bcryptjs");
const jwt=require("jsonwebtoken");
const auth = require("../middlewares/auth");

const authRouter=express.Router();

// in post request we
authRouter.post('/api/signup',async(req,res)=>{
  try {
      // step 1 get data ------------------
   const {name,email,password} =req.body;
   console.log(req.body);
   //    step 2 send to database----------------
   const exsistingUser= await User.findOne({email:email,});
   if(exsistingUser){
       return res.status(400).json({msg:"User with same email already exists!"});
       // satus(400) to specify that its en error
       // must use return or it will execute further
   }
   
  //  hashing the passwords 8 is salt
  const hashedPassword=await bcryptjs.hash(password,8);
  
   // creating new user of user model from user.js
   let user= new User({
       name,email,password:hashedPassword
   })
   user=await user.save();
   
   // Step 3  send respose to client----------
   res.json(user);
  } catch (e) {
    res.status(500).json({error:e.message});
  }
});

// sign in route

// TODO 
// make schema done
// data is coming
// do user.deviceToken=deviceToken;
// user.save

authRouter.post('/api/signin',async(req,res)=>{
  try {
    const {email,password,deviceToken}=req.body;
  //  console.log(req.body);
   

   const user=await User.findOne({email});
  //  console.log(admintype);
   if(!user){
    return res.status(400).json({msg:"User with this email does not exsist"})
   }else{
    user.deviceToken=deviceToken;
   user.save();
   }
// our password is hasehed so we need to compare it 
const isMatched=await bcryptjs.compare(password,user.password);
if(!isMatched){
  return res.status(400).json({msg:"incorect password"})

}
// token
const token=jwt.sign({id:user._id},"passwordKey")
res.json({token,...user._doc});
  } catch (error) {
     res.status(500).json({error:error.message});
  }
});

// Tto check if token is valid

authRouter.post('/tokenIsValid',async(req,res)=>{
  try {
   const token=req.header("x-auth-token");
  //  to heck if there is a token
   if(!token){return res.json(false);} 
  //  to verify token
   const verified=jwt.verify(token,'passwordKey');
   if(!verified){return res.json(false);} 
  //  to check if there is a user
  const user=await User.findById(verified.id);
  if(!user){
    return res.json(false); 
  }
  res.json(true);

  } catch (error) {
     res.status(500).json({error:error.message});
  }
});

// to get user data
authRouter.get('/',auth,async(req,res)=>{
  const user=await User.findById(req.user);
  res.json({...user._doc,token:req.token})
})

module.exports=authRouter;