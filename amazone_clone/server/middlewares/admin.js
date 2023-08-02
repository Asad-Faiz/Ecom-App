const jwt=require('jsonwebtoken');
const User=require('../models/user');
const admin=async(req,res,next)=>{
    try {
        const token=req.header('x-auth-token');
        if(!token){
            return res.status(401).json({msg:"no auth token, access denied"})
        }
        //  to verify token
   const verified=jwt.verify(token,'passwordKey');
   if(!verified){return res.status(401).json({msg:"Token Verification Failed"})} 
   const user=await User.findById(verified.id);
   if(user.type=='user'||user.type=='seller'){
    return res.status(401).json({msg:"you are not an admin"});
   }
   req.user=verified.id;
   req.token=token;
   next();
    } catch (error) {
        res.status(500).json({error:error.message})
        
    }
}
module.exports=admin;