/* bossMenu.js */

window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === 'openBossMenu') {
        document.querySelector('.container').style.display = 'flex';
        openMainBossMenu();
    } else if (data.action === 'updateEmployeeList') {
        updateEmployeeList(data.employees);
    }
});

// Fonction pour sélectionner une action du menu boss
function selectBossOption(action, employeeId = null, newGrade = null, minutes = null) {
    fetch(`https://${GetParentResourceName()}/bossMenuAction`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({ action, employeeId, newGrade, minutes })
    });
}

// Fonction pour ouvrir un sous-menu et fermer les autres
function openSubMenu(subMenuId) {
    document.querySelectorAll('.menu-content, .subMenu').forEach(menu => menu.classList.remove('active'));
    document.getElementById(subMenuId).classList.add('active');

    // Charger les employés si on ouvre la gestion des employés
    if (subMenuId === 'employeeManagementMenu') {
        fetchEmployees();
    }
}

// Fonction pour retourner au menu principal
function backToMainBossMenu() {
    document.querySelectorAll('.subMenu').forEach(menu => menu.classList.remove('active'));
    document.getElementById('mainBossMenu').classList.add('active');
}

// Fonction pour fermer le menu boss
function closeBossMenu() {
    document.querySelector('.container').style.display = 'none';
    fetch(`https://${GetParentResourceName()}/bossMenuAction`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({ action: 'close' })
    });
}

// Fonction pour charger la liste des employés
function fetchEmployees() {
    fetch(`https://${GetParentResourceName()}/bossMenuAction`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({ action: 'getEmployees' })
    });
}

// Fonction pour mettre à jour la liste des employés dans l'UI
function updateEmployeeList(employees) {
    const employeeList = document.getElementById('employeeList');
    employeeList.innerHTML = '';

    if (employees.length === 0) {
        const li = document.createElement('li');
        li.classList.add('empty');
        li.textContent = "Aucun employé trouvé";
        employeeList.appendChild(li);
    } else {
        employees.forEach(employee => {
            const li = document.createElement('li');
            li.innerHTML = `
                <span>${employee.name}</span>
                <button class="btn btn-secondary" onclick="selectBossOption('fire', ${employee.id})">Virer</button>
                <button class="btn btn-secondary" onclick="openManageGrade(${employee.id})">Gérer le Grade</button>
                <button class="btn btn-secondary" onclick="openManageTime(${employee.id})">Gérer le Temps</button>
            `;
            employeeList.appendChild(li);
        });
    }
}

// Fonction pour gérer le grade d'un employé
function openManageGrade(employeeId) {
    const gradeOptions = document.getElementById('gradeManagementOptions');
    gradeOptions.innerHTML = `
        <li>
            <button class="btn" onclick="selectBossOption('setGrade', ${employeeId}, 1)">Promouvoir</button>
            <button class="btn" onclick="selectBossOption('setGrade', ${employeeId}, -1)">Rétrograder</button>
        </li>
    `;
    openSubMenu('manageGradesMenu');
}

// Fonction pour gérer le temps de service d'un employé
function openManageTime(employeeId) {
    const timeManagementList = document.getElementById('timeManagementList');
    timeManagementList.innerHTML = `
        <li>
            <span>Ajouter du Temps :</span>
            <input type="number" id="addTimeInput" min="1" max="999">
            <button class="btn btn-secondary" onclick="submitTimeChange(${employeeId}, 'add')">Ajouter</button>
        </li>
        <li>
            <span>Supprimer du Temps :</span>
            <input type="number" id="removeTimeInput" min="1" max="999">
            <button class="btn btn-secondary" onclick="submitTimeChange(${employeeId}, 'remove')">Supprimer</button>
        </li>
    `;
    openSubMenu('timeManagementMenu');
}

// Fonction pour soumettre les modifications de temps de service
function submitTimeChange(employeeId, action) {
    const minutes = action === 'add'
        ? document.getElementById('addTimeInput').value
        : document.getElementById('removeTimeInput').value;

    selectBossOption(`${action}Time`, employeeId, null, parseInt(minutes));
    backToMainBossMenu();
}

// Gestion des clics sur les options du menu principal pour ouvrir les sous-menus
document.querySelectorAll('.option').forEach(option => {
    option.addEventListener('click', function() {
        const subMenuId = this.getAttribute('data-submenu');
        openSubMenu(subMenuId);
    });
});
