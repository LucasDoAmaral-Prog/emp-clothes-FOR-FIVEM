const btn_Close   = document.getElementsByClassName("close")[0];
const btn_Tissue  = document.getElementsByClassName("btn-Tissue")[0];
const btn_Needle  = document.getElementsByClassName("btn-Needle")[0];
const btn_Buttons = document.getElementsByClassName("btn-Buttons")[0];

const body = document.getElementsByTagName('body')[0];

addEventListener("message", function(event){

    event.data.isOpen = event.data.isOpen ?  body.style = 'display: block;' : body.style = 'display: none;';

})

addEventListener("keydown", (e) => {

    if (e.key === 'Escape') {

        body.style = 'display: none';

        requisitionHTTP(JSON.stringify({isOpen: "close"}));

    }

})

btn_Close.onclick = () => {
            
    body.style = 'display: none';

    requisitionHTTP(JSON.stringify({isOpen: "close"}));
    
}

btn_Tissue.onclick = () => {

    requisitionHTTP(JSON.stringify({tissueClicked: true}));

}

btn_Needle.onclick = () => {

    requisitionHTTP(JSON.stringify({needleClicked: true}));

}

btn_Buttons.onclick = () => {

    requisitionHTTP(JSON.stringify({buttonsClicked: true}));

}

const requisitionHTTP = (value) => {

    fetch("https://jobsvoltz/close", {

        method: "POST",

        headears: {

            "Content-Type" : "application/json",
            
        },

        body: value,

    });

}