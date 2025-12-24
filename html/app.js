let currentData = {
    speed: 0,
    rpm: 0,
    gear: 0,
    engine: true,
    seatbelt: true,
    unit: 'kmh',
    maxSpeed: 300
};

let config = {
    unit: 'kmh',
    maxSpeed: 300,
    position: 'bottom-right',
    theme: 'dark',
    showRPM: true,
    showGear: true,
    showSeatbelt: true,
    showEngine: true
};

const speedometerEl = document.getElementById('speedometer');
const speedValueEl = document.getElementById('speedValue');
const speedUnitEl = document.getElementById('speedUnit');
const gaugeFillEl = document.querySelector('.gauge-fill');
const rpmInfoEl = document.getElementById('rpmInfo');
const rpmValueEl = document.getElementById('rpmValue');
const gearInfoEl = document.getElementById('gearInfo');
const gearValueEl = document.getElementById('gearValue');
const engineInfoEl = document.getElementById('engineInfo');
const engineValueEl = document.getElementById('engineValue');
const seatbeltInfoEl = document.getElementById('seatbeltInfo');
const seatbeltValueEl = document.getElementById('seatbeltValue');

const CIRCUMFERENCE = 2 * Math.PI * 90;

function init(data) {
    config = { ...config, ...data.config };
    
    speedometerEl.setAttribute('data-position', config.position);
    speedometerEl.setAttribute('data-theme', config.theme);
    
    rpmInfoEl.style.display = config.showRPM ? 'flex' : 'none';
    gearInfoEl.style.display = config.showGear ? 'flex' : 'none';
    engineInfoEl.style.display = config.showEngine ? 'flex' : 'none';
    seatbeltInfoEl.style.display = config.showSeatbelt ? 'flex' : 'none';
    
    updateSpeedUnit();
}

function updateSpeedUnit() {
    speedUnitEl.textContent = config.unit === 'mph' ? 'mph' : 'km/h';
}

function updateSpeed(speed) {
    if (speed === currentData.speed) return;
    
    currentData.speed = speed;
    
    requestAnimationFrame(() => {
        speedValueEl.textContent = Math.floor(speed);
        
        const percentage = Math.min(speed / currentData.maxSpeed, 1);
        const offset = CIRCUMFERENCE - (CIRCUMFERENCE * percentage);
        gaugeFillEl.style.strokeDashoffset = offset;
    });
}

function updateRPM(rpm) {
    if (rpm === currentData.rpm) return;
    
    currentData.rpm = rpm;
    rpmValueEl.textContent = rpm;
}

function updateGear(gear) {
    if (gear === currentData.gear) return;
    
    currentData.gear = gear;
    
    let gearText = 'N';
    if (gear === 0) {
        gearText = 'R';
    } else if (gear > 0) {
        gearText = gear.toString();
    }
    
    gearValueEl.textContent = gearText;
}

function updateEngine(engine) {
    if (engine === currentData.engine) return;
    
    currentData.engine = engine;
    
    engineValueEl.textContent = engine ? 'ON' : 'OFF';
    engineInfoEl.classList.toggle('engine-off', !engine);
}

function updateSeatbelt(seatbelt) {
    if (seatbelt === currentData.seatbelt) return;
    
    currentData.seatbelt = seatbelt;
    
    seatbeltValueEl.textContent = seatbelt ? '✓' : '✗';
    seatbeltInfoEl.classList.toggle('seatbelt-off', !seatbelt);
}

function show() {
    speedometerEl.classList.remove('hidden');
}

function hide() {
    speedometerEl.classList.add('hidden');
}
function update(data) {
    if (data.speed !== undefined) {
        updateSpeed(data.speed);
    }
    
    if (data.rpm !== undefined) {
        updateRPM(data.rpm);
    }
    
    if (data.gear !== undefined) {
        updateGear(data.gear);
    }
    
    if (data.engine !== undefined) {
        updateEngine(data.engine);
    }
    
    if (data.seatbelt !== undefined) {
        updateSeatbelt(data.seatbelt);
    }
    
    if (data.unit && data.unit !== config.unit) {
        config.unit = data.unit;
        updateSpeedUnit();
    }
    
    if (data.maxSpeed && data.maxSpeed !== currentData.maxSpeed) {
        currentData.maxSpeed = data.maxSpeed;
    }
}

window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch (data.action) {
        case 'init':
            init(data);
            break;
        case 'show':
            show();
            break;
        case 'hide':
            hide();
            break;
        case 'update':
            update(data);
            break;
    }
});

hide();

