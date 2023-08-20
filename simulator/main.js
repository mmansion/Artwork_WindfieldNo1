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


//-------------------------------------------
const scene = new THREE.Scene();

//-------------------------------------------
//add an arrow helper for the x, y, z axis
const axesHelper = new THREE.AxesHelper(100);
scene.add(axesHelper);

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
addGrid();


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
        console.log(groupPos);
        this._group.position.set(groupPos.x, groupPos.y, groupPos.z);
        
        let size = TILE_SIZE * UNITS_PER_FOOT
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
        
        // return this;

        // this._geometry = new THREE.PlaneGeometry(100, 100);
        // this._material = new THREE.MeshBasicMaterial({ color: 0x0000ff });
        // this._object   = new THREE.Mesh(this._geometry, this._material);
        // this._object.position.set(pos.x, pos.y, pos.z);
    }
    get group() {
        console.log('here');
        // return this._group;
    }
    addToScene(scene) {
        scene.add(this._group);
    }
    addToGroup(group) {
        group.add(this._group);
    }
}

let tilePos1 = {x: 0, y:0, z: -(UNITS_PER_FOOT*TILE_SIZE)*1};
let tile1 = new Tile(tilePos1).addToScene(scene);

let tilePos2 = { x: 0, y: 0, z: -(UNITS_PER_FOOT * TILE_SIZE) * 2 };
let tile2 = new Tile(tilePos2).addToScene(scene);

//-------------------------------------------
let toggleOrtho = false;

const frustumSize = 500;
scene.background = new THREE.Color(0xffffff);

const aspect = window.innerWidth / window.innerHeight;

let camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 10000);
const renderer = new THREE.WebGLRenderer();
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);

let controls = new OrbitControls(camera, renderer.domElement);
controls.addEventListener("change", event => {
    console.log(controls.object.position);
});
controls.update();

camera.position.set(598, 598, 598);
camera.zoom = 4;
camera.lookAt(0, 0, 0);


function animate() {
    requestAnimationFrame(animate);
    renderer.render(scene, camera);
}

let cpanel = new ControlPanel(camera);

//last step
animate();




//     window.addEventListener('resize', onWindowResize);
//     createPanel();

// }

// function onWindowResize() {

//     const aspect = window.innerWidth / window.innerHeight;

//     camera.left = - frustumSize * aspect / 2;
//     camera.right = frustumSize * aspect / 2;
//     camera.top = frustumSize / 2;
//     camera.bottom = - frustumSize / 2;

//     camera.updateProjectionMatrix();

//     renderer.setSize(window.innerWidth, window.innerHeight);

//     // renderer2.setSize(window.innerWidth, window.innerHeight);

// }

// function animate() {

//     requestAnimationFrame(animate);

//     renderer.render(scene, camera);
//     // renderer2.render(scene2, camera);

// }

// function createPanel() {

//     const panel = new GUI();
//     const folder1 = panel.addFolder('camera setViewOffset').close();

//     const settings = {
//         'setViewOffset'() {

//             folder1.children[1].enable().setValue(window.innerWidth);
//             folder1.children[2].enable().setValue(window.innerHeight);
//             folder1.children[3].enable().setValue(0);
//             folder1.children[4].enable().setValue(0);
//             folder1.children[5].enable().setValue(window.innerWidth);
//             folder1.children[6].enable().setValue(window.innerHeight);

//         },
//         'fullWidth': 0,
//         'fullHeight': 0,
//         'offsetX': 0,
//         'offsetY': 0,
//         'width': 0,
//         'height': 0,
//         'clearViewOffset'() {

//             folder1.children[1].setValue(0).disable();
//             folder1.children[2].setValue(0).disable();
//             folder1.children[3].setValue(0).disable();
//             folder1.children[4].setValue(0).disable();
//             folder1.children[5].setValue(0).disable();
//             folder1.children[6].setValue(0).disable();
//             camera.clearViewOffset();

//         }
//     };

//     folder1.add(settings, 'setViewOffset');
//     folder1.add(settings, 'fullWidth', window.screen.width / 4, window.screen.width * 2, 1).onChange((val) => updateCameraViewOffset({ fullWidth: val })).disable();
//     folder1.add(settings, 'fullHeight', window.screen.height / 4, window.screen.height * 2, 1).onChange((val) => updateCameraViewOffset({ fullHeight: val })).disable();
//     folder1.add(settings, 'offsetX', 0, 256, 1).onChange((val) => updateCameraViewOffset({ x: val })).disable();
//     folder1.add(settings, 'offsetY', 0, 256, 1).onChange((val) => updateCameraViewOffset({ y: val })).disable();
//     folder1.add(settings, 'width', window.screen.width / 4, window.screen.width * 2, 1).onChange((val) => updateCameraViewOffset({ width: val })).disable();
//     folder1.add(settings, 'height', window.screen.height / 4, window.screen.height * 2, 1).onChange((val) => updateCameraViewOffset({ height: val })).disable();
//     folder1.add(settings, 'clearViewOffset');

// }

// function updateCameraViewOffset({ fullWidth, fullHeight, x, y, width, height }) {

//     if (!camera.view) {

//         camera.setViewOffset(fullWidth || window.innerWidth, fullHeight || window.innerHeight, x || 0, y || 0, width || window.innerWidth, height || window.innerHeight);

//     } else {

//         camera.setViewOffset(fullWidth || camera.view.fullWidth, fullHeight || camera.view.fullHeight, x || camera.view.offsetX, y || camera.view.offsetY, width || camera.view.width, height || camera.view.height);

//     }

// }