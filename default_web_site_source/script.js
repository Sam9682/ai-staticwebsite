function handleSubmit(event) {
    event.preventDefault();
    alert("Ce site est un exemple statique. Le formulaire n'est pas relié à une véritable adresse email.");
}

document.addEventListener("DOMContentLoaded", function () {
    var yearSpan = document.getElementById("year");
    if (yearSpan) {
        yearSpan.textContent = new Date().getFullYear();
    }
});
