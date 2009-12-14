function replaceTimeStamp(oldstamp,newstamp)
{
        oldregexp = new RegExp(oldstamp,"gi")
document.body.innerHTML= document.body.innerHTML.replace(oldregexp,newstamp);

}

