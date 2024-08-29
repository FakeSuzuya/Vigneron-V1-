window.addEventListener('message', function(event) {
    if (event.data.action == 'openStorage') {
        document.getElementById('storageMenu').style.display = 'block';
        updateInventory(event.data.storageItems, event.data.playerItems);
    }
});

document.getElementById('closeBtn').addEventListener('click', function() {
    const storageMenu = document.getElementById('storageMenu');
    storageMenu.classList.add('closing');
    setTimeout(() => {
        storageMenu.style.display = 'none';
        storageMenu.classList.remove('closing');
    }, 300);
    $.post('http://your_resource_name/closeStorage', JSON.stringify({}));
});

document.getElementById('searchInput').addEventListener('input', function() {
    const searchTerm = this.value.toLowerCase();
    const items = document.querySelectorAll('#itemList li, #playerItemList li');

    items.forEach(item => {
        const itemName = item.textContent.toLowerCase();
        if (itemName.includes(searchTerm)) {
            item.style.display = 'block';
        } else {
            item.style.display = 'none';
        }
    });
});

document.getElementById('sortSelect').addEventListener('change', function() {
    const sortValue = this.value;
    sortItems(sortValue);
});

function sortItems(sortBy) {
    const itemList = document.getElementById('itemList');
    const playerItemList = document.getElementById('playerItemList');
    const items = Array.from(itemList.children);
    const playerItems = Array.from(playerItemList.children);

    items.sort((a, b) => compareItems(a, b, sortBy));
    playerItems.sort((a, b) => compareItems(a, b, sortBy));

    itemList.innerHTML = '';
    playerItemList.innerHTML = '';

    items.forEach(item => itemList.appendChild(item));
    playerItems.forEach(item => playerItemList.appendChild(item));
}

function compareItems(a, b, sortBy) {
    if (sortBy === 'name') {
        return a.textContent.localeCompare(b.textContent);
    } else if (sortBy === 'count') {
        const countA = parseInt(a.textContent.match(/\((\d+)\)/)[1]);
        const countB = parseInt(b.textContent.match(/\((\d+)\)/)[1]);
        return countB - countA;
    }
}

function updateInventory(storageItems, playerItems) {
    const itemList = document.getElementById('itemList');
    const playerItemList = document.getElementById('playerItemList');

    itemList.innerHTML = '';
    playerItemList.innerHTML = '';

    storageItems.forEach(item => {
        const li = document.createElement('li');
        li.textContent = `${item.label} (${item.count})`;
        const button = document.createElement('button');
        button.textContent = 'Retirer';
        button.onclick = function() {
            const quantity = parseInt(document.getElementById('quantity').value);
            if (quantity > 0 && quantity <= item.count) {
                $.post('http://your_resource_name/retrieveItem', JSON.stringify({
                    itemName: item.name,
                    count: quantity
                }));
            }
        };
        li.appendChild(button);
        itemList.appendChild(li);
    });

    playerItems.forEach(item => {
        const li = document.createElement('li');
        li.textContent = `${item.label} (${item.count})`;
        const button = document.createElement('button');
        button.textContent = 'Déposer';
        button.onclick = function() {
            const quantity = parseInt(document.getElementById('quantity').value);
            if (quantity > 0 && quantity <= item.count) {
                $.post('http://your_resource_name/storeItem', JSON.stringify({
                    itemName: item.name,
                    count: quantity
                }));
            }
        };
        li.appendChild(button);
        playerItemList.appendChild(li);
    });
}
