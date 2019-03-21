function buttonEnable1() {
    document.getElementById('Button1').removeAttribute('disabled');
}

function buttonEnable2() {
    document.getElementById('Button2').removeAttribute('disabled');
}

function buttonEnable3() {
    document.getElementById('Button3').removeAttribute('disabled');
}

function disTable() {
    document.getElementById('tablecontainer').style.display = 'block';
}

dateOfBirth.addEventListener('input', function(evt) {
    if (document.getElementById('cdd3').checked) {
        buttonEnable();
    }
});

checkbox1 = document.getElementById('cdd1');

checkbox1.addEventListener('change', e => {

    if (e.target.checked) {
        if (document.getElementById('aNumber').value == "") {
            alert('Enter a value');
            document.getElementById('aNumber').focus;
            return false;
        } else {
            buttonEnable1();
            return true;
        }
    }

});

checkbox2 = document.getElementById('cdd2');

checkbox2.addEventListener('change', e => {

    if (e.target.checked) {
        if (document.getElementById('firstName').value == "") {
            alert('Enter a value');
            document.getElementById('firstName').focus;
            return false;
        } else if (document.getElementById('lastName').value == "") {
            alert('Enter a value');
            document.getElementById('lastName').focus;
            return false;
        } else {
            buttonEnable2();
            return true;
        }
    }
});

checkbox3 = document.getElementById('cdd3');

checkbox3.addEventListener('change', e => {

    if (e.target.checked) {
        if (document.getElementById('dateOfBirth').value == "") {
            alert('Enter a value');
            document.getElementById('dateOfBirth').focus;
            return false;
        } else {
            buttonEnable3();
            return true;
        }
    }

});
