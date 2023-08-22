import * as THREE from 'three';

import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { GUI } from 'three/addons/libs/lil-gui.module.min.js';

//import control panel from public folder
import ControlPanel from './public/ControlPanel.js';

//-------------------------------------------
//SETTTINGS

const UNITS_PER_FOOT = 100;
const TILE_SIZE = 4; //ft
const PIXELS_PER_FOOT = 4;
const PIXEL_SIZE = 5;

const tileGrid = [ //rows: W->E, cols: N->S
    // a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p
    [  0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0 ], // 1
    [  1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0 ], // 2
    [  1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1 ], // 3
    [  0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1 ], // 4
    [  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1 ], // 5
];

//-------------------------------------------
let mesh, mesh2, renderer, scene, camera, controls;
let count = 0;



function animate() {

    requestAnimationFrame(animate);
    renderer.render(scene, camera);

}

function addHelpers() {
    //add an arrow helper for the x, y, z axis
    const axesHelper = new THREE.AxesHelper(100);
    scene.add(axesHelper);
}



// const scene = new THREE.Scene();

//-------------------------------------------


function addGrid() {

    const size = 1000;
    const divisions = 10;
 
    const gridHelper = new THREE.GridHelper(size, divisions);
    
    //change color of grid lines
    // gridHelper.material.color = new THREE.Color(0x0000ff);
    
    //change material of grid lines
    gridHelper.material = new THREE.LineBasicMaterial({
        // make a transparent line color
        color: 0x0000ff,
        opacity: 0.2,
        transparent: true,
        //make thin lines
        linewidth: 1
    });

    scene.add(gridHelper);
}



//-------------------------------------------

class Led {
    constructor(pos) {
        this._geometry = new THREE.SphereGeometry(PIXEL_SIZE, 16, 16);
        this._material = new THREE.MeshBasicMaterial({ color: 0x0000ff });
        this._object   = new THREE.Mesh(this._geometry, this._material);
        this._object.position.set(pos.x, pos.y, pos.z);
    }
    addToScene(scene) {
        scene.add(this._object);
    }
    addToGroup(group) {
        group.add(this._object);
    }
}

class Tile {
    constructor(pos) {
        this._group = new THREE.Group();
        this._group.position.set(UNITS_PER_FOOT/2, 0, UNITS_PER_FOOT/2);
        let groupPos = this._group.position;
        groupPos.x += pos.x;
        groupPos.y += pos.y;
        groupPos.z += pos.z;

        this._group.position.set(groupPos.x, groupPos.y, groupPos.z);
        
        let size = TILE_SIZE * UNITS_PER_FOOT;

        const geometry = new THREE.PlaneGeometry(size, size);   
        const material = new THREE.MeshBasicMaterial({ color: 0x000000, wireframe: true, wireframeLinewidth: 40, side: THREE.DoubleSide });
        const plane = new THREE.Mesh(geometry, material);
        plane.rotation.x = Math.PI / 2;
        plane.position.set(size / 2 - UNITS_PER_FOOT/2, 0, size/2-UNITS_PER_FOOT/2);
        this._group.add(plane);

        // console.log(this._group.position);
        
        //create a 4x4 grid of leds
        for (let i = 0; i < PIXELS_PER_FOOT; i++) {
            for (let j = 0; j < PIXELS_PER_FOOT; j ++) {
                let led = new Led({ 
                    x: i * UNITS_PER_FOOT, 
                    y: 0, z: j * UNITS_PER_FOOT 
                });
                led.addToGroup(this._group);
            }
        }
    }
    addToScene(scene) {
        scene.add(this._group);
    }
    addToGroup(group) {
        group.add(this._group);
    }
}



//-------------------------------------------
// let toggleOrtho = false;


// let aspect = window.innerWidth / window.innerHeight;

// const frustumSize = 5000;
// // const aspect = window.innerWidth / window.innerHeight;

// scene.background = new THREE.Color(0xffffff);

// let viewBlock = 5000;
// let camera = new THREE.OrthographicCamera(-viewBlock * aspect, viewBlock * aspect, viewBlock, -viewBlock, -10000, 10000);
// // camera.position.set(0, 0, 100);
// camera.position.set(0, -1, 0);
// camera.lookAt(0, 0, 0);
// // camera.translateZ(-100);
// camera.updateProjectionMatrix();


// // let camera = new THREE.OrthographicCamera(0.5 * frustumSize * aspect / - 2, 0.5 * frustumSize * aspect / 2, frustumSize / 2, frustumSize / - 2, 0.01, 100000);
// // let camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 100000);
// // let camera = new THREE.OrthographicCamera(width / - 2, width / 2, height / 2, height / - 2, 0.01, 100000);

// // const renderer = new THREE.WebGLRenderer();
// const renderer = new THREE.WebGLRenderer({ antialias: false });
// renderer.setSize(window.innerWidth, window.innerHeight);
// document.body.appendChild(renderer.domElement);
// renderer.domElement.style.imageRendering = 'pixelated'; //PB-2
// renderer.domElement.style.transform = "scale(0.8,0.8)"; //PB-3
// window.addEventListener("resize", onWindowResize, false);

// let controls = new OrbitControls(camera, renderer.domElement);
// controls.addEventListener("change", event => {
//     console.log(controls.object.position);
// });
// // controls.object.position.set(17, 19, 3500);
// controls.update();

// camera.translateZ(-10);
// camera.up.angleTo(new THREE.Vector3(0, 1, 0));
// camera.position.set(10, 10, 10);

// camera.lookAt(0, 0, 1);
// camera.zoom = 1;
// camera.updateProjectionMatrix();


// camera.updateProjectionMatrix();
// camera.zoom = 0.1;
// camera.updateProjectionMatrix();
// camera.lookAt(0, 0, 1);
// camera.updateProjectionMatrix();
// camera.updateProjectionMatrix();

// function animate() {
//     requestAnimationFrame(animate);
//     renderer.render(scene, camera);
// }



// //last step
// animate();

// function onWindowResize() {
//     camera.left = window.innerWidth / -2;
//     camera.right = window.innerWidth / 2;
//     camera.top = window.innerHeight / 2;
//     camera.bottom = window.innerHeight / -2;

//     camera.updateProjectionMatrix();
//     renderer.setSize(window.innerWidth, window.innerHeight);
// }
function init() {

    // renderer
    renderer = new THREE.WebGLRenderer();
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setPixelRatio(window.devicePixelRatio);
    document.body.appendChild(renderer.domElement);

    // scene
    scene = new THREE.Scene();
    scene.background = new THREE.Color(0xffffff);

    // camera
    const frustumSize = 1000;
    const aspect = window.innerWidth / window.innerHeight;

    camera = new THREE.OrthographicCamera(frustumSize * aspect / - 2, frustumSize * aspect / 2, frustumSize / 2, frustumSize / - 2, 0, 100);
    camera.up.set(0, 0, 1);
    camera.position.set(5, 0, 10);

    // controls
    controls = new OrbitControls(camera, renderer.domElement);
    controls.touches.ONE = THREE.TOUCH.PAN;
    controls.touches.TWO = THREE.TOUCH.DOLLY_ROTATE;
    controls.target.set(5, 0, 0);
    controls.update();

    // ambient
    // scene.add(new THREE.AmbientLight(0xffffff));

    // light
    var light = new THREE.DirectionalLight(0xffffff, 10);
    light.position.set(0, 2, 2);
    // scene.add(light);

    // axes
    scene.add(new THREE.AxesHelper(20));

    // geometry
    var geometry = new THREE.PlaneGeometry(5, 5);

    // material
    var material = new THREE.MeshPhongMaterial({
        color: 0x00ffff,
        side: THREE.DoubleSide
    });


    // mesh
    mesh = new THREE.Mesh(geometry, material);
    scene.add(mesh);

    var geometry2 = new THREE.PlaneGeometry(3, 3);
    var material2 = new THREE.MeshPhongMaterial({
        color: 0x00ffff,
        side: THREE.DoubleSide
    });
    mesh2 = new THREE.Mesh(geometry2, material2);
    mesh2.position.x = 5;
    scene.add(mesh2);

    addGrid();
    addHelpers();

    //loop through tileGrid and add tiles to scene
    for (let i = 0; i < tileGrid.length; i++) {
        for (let j = 0; j < tileGrid[i].length; j++) {
            if (tileGrid[i][j] === 1) {
                let tilePos = { x: i * UNITS_PER_FOOT * TILE_SIZE * -1, y: 0, z: j * UNITS_PER_FOOT * TILE_SIZE };
                let tile = new Tile(tilePos).addToScene(scene);
            }
        }
    }

    animate();

    let cpanel = new ControlPanel(camera);
}

init();