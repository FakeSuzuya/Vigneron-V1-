/* menu.js */

window.addEventListener('message', function(event) {
    const data = event.data;
    if (data.action === 'openMenu') {
        document.querySelector('.container').style.display = 'flex';
        openMainMenu();
    } else if (data.action === 'updateWinePrice') {
        document.getElementById('winePrice').textContent = data.price;
    } else if (data.action === 'updateEmployeeList') {
        const employeeList = document.getElementById('employeeList');
        employeeList.innerHTML = '';
        if (data.employees.length === 0) {
            const li = document.createElement('li');
            li.classList.add('empty');
            li.textContent = "Aucun employé en service";
            employeeList.appendChild(li);
        } else {
            data.employees.forEach(employee => {
                const li = document.createElement('li');
                li.textContent = employee;
                employeeList.appendChild(li);
            });
        }
    }
});

// Fonction pour sélectionner une action du menu
function selectOption(action) {
    fetch(`https://${GetParentResourceName()}/menuAction`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({ action: action })
    });
    backToMainMenu();
}

// Fonction pour ouvrir un sous-menu et fermer les autres
function openSubMenu(subMenuId) {
    document.querySelectorAll('.menu-content, .subMenu').forEach(menu => menu.classList.remove('active'));
    document.getElementById(subMenuId).classList.add('active');
}

// Fonction pour retourner au menu principal
function backToMainMenu() {
    document.querySelectorAll('.subMenu').forEach(menu => menu.classList.remove('active'));
    document.getElementById('mainMenu').classList.add('active');
}

// Fonction pour fermer le menu principal
function closeMenu() {
    document.querySelector('.container').style.display = 'none';
    fetch(`https://${GetParentResourceName()}/menuAction`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({ action: 'close' })
    });
}

// Gestion des clics sur les options du menu principal pour ouvrir les sous-menus
document.querySelectorAll('.option').forEach(option => {
    option.addEventListener('click', function() {
        const subMenuId = this.getAttribute('data-submenu');
        openSubMenu(subMenuId);
    });
});
