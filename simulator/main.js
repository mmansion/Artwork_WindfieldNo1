import * as THREE from 'three';

import { OrbitControls } from 'three/addons/controls/OrbitControls.js';
import { CSS3DRenderer, CSS3DObject } from 'three/addons/renderers/CSS3DRenderer.js';
import { GUI } from 'three/addons/libs/lil-gui.module.min.js';

let toggleOrtho = true;

const frustumSize = 500;
const scene = new THREE.Scene();
scene.background = new THREE.Color(0xffffff);

const aspect = window.innerWidth / window.innerHeight;

// const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
let camera = new THREE.OrthographicCamera(frustumSize * aspect / - 2, frustumSize * aspect / 2, frustumSize / 2, frustumSize / - 2, 0.1, 1000);

const renderer = new THREE.WebGLRenderer();
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);

const geometry = new THREE.BoxGeometry(100, 100, 100);
// const material = new THREE.MeshBasicMaterial({ color: 0x00ff00 });
const material = new THREE.MeshBasicMaterial({ color: 0x000000, wireframe: true, wireframeLinewidth: 40, side: THREE.DoubleSide });
const cube = new THREE.Mesh(geometry, material);
// scene.add(cube);



//plane geometry
const planeGeom = new THREE.PlaneGeometry(100, 100);
// const material = new THREE.MeshBasicMaterial({ color: 0xffff00, side: THREE.DoubleSide });
const plane = new THREE.Mesh(planeGeom, material);
scene.add(plane);

camera.position.set(0, 0, 1000);

function addSphere() {
    const geometry = new THREE.SphereGeometry(15, 32, 16);
    const material = new THREE.MeshBasicMaterial({ color: 0x0000ff });
    const sphere = new THREE.Mesh(geometry, material); scene.add(sphere);
    scene.add(sphere);
}
addSphere();

function animate() {
    requestAnimationFrame(animate);
    cube.rotation.x += 0.01;
    cube.rotation.y += 0.01;
    renderer.render(scene, camera);
}
createPanel();
animate();

function createPanel() {

    const panel = new GUI();
    const f1 = panel.addFolder('camera').open();


    let settings = {
        zoom: () => {
            camera.position.set(0, 0, 1000);
            camera.up.set(0, 0, -1);
            camera.updateProjectionMatrix();
        },
        handleClick: function () {
            if (toggleOrtho) {
                camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);

                camera.position.z = 500;
                toggleOrtho = false;
            } else {
                camera = new THREE.OrthographicCamera(frustumSize * aspect / - 2, frustumSize * aspect / 2, frustumSize / 2, frustumSize / - 2, 0.1, 1000);
                camera.position.z = 100;
                toggleOrtho = true;
            }
        }
    };

    // folder1.add(settings, 'handleClick').name('toggle camera');
    f1.add(camera.position, 'z', 1, 2).onChange( (value) => {
        // make camera look down
        camera.position.set(0, 0, 1000);
        camera.zoom = value;
        console.log(value);
    });
    // camera.position.z = 100;
    // let zoomControl = f1.add(settings, 'zoom').name('zoom');
    // zoomControl.onChange(function (value) {
    //     console.log(value);
    // });

    //add a button
    f1.add(settings, 'handleClick').name('toggle camera');

 
}

// let scene2, renderer2;

// const frustumSize = 500;

// init();
// animate();

// function init() {
    
//     const scene = new THREE.Scene();
   
//     const aspect = window.innerWidth / window.innerHeight;
    // camera = new THREE.OrthographicCamera(frustumSize * aspect / - 2, frustumSize * aspect / 2, frustumSize / 2, frustumSize / - 2, 1, 1000);
    // scene.background = new THREE.Color(0xf0f0f0);


    // // make the camera look down
    // camera.position.set(0, 10, 0);
    // camera.up.set(0, 0, -1);

    // //The lookAt() method calls are necessary so the camera looks at the coordinates systems origin 
    // //or at the position of the scene (which is more or less the root object of the scene graph). 
    // //In most cases, the position value of scene is (0,0,0) (the origin).
    // camera.lookAt(0, 0, 0);
    


    // scene2 = new THREE.Scene();

    // const material = new THREE.MeshBasicMaterial({ color: 0x000000, wireframe: true, wireframeLinewidth: 40, side: THREE.DoubleSide });

    // const geometry = new THREE.BoxGeometry(100, 100, 100);
    // // const material = new THREE.MeshBasicMaterial({ color: 0x00ff00 });
    // const cube = new THREE.Mesh(geometry, material);
    // scene.add(cube);

    // left
    // createPlane(
    //     100, 100,
    //     'chocolate',
    //     new THREE.Vector3(- 50, 0, 0),
    //     new THREE.Euler(0, - 90 * THREE.MathUtils.DEG2RAD, 0)
    // );
    // // right
    // createPlane(
    //     100, 100,
    //     'saddlebrown',
    //     new THREE.Vector3(0, 0, 50),
    //     new THREE.Euler(0, 0, 0)
    // );
    // // top
    // createPlane(
    //     100, 100,
    //     'yellowgreen',
    //     new THREE.Vector3(0, 50, 0),
    //     new THREE.Euler(- 90 * THREE.MathUtils.DEG2RAD, 0, 0)
//     // );
//     // bottom
//     createPlane(
//         300, 300,
//         'blue',
//         new THREE.Vector3(0, - 50, 0),
//         new THREE.Euler(- 90 * THREE.MathUtils.DEG2RAD, 0, 0)
//     );

//     renderer = new THREE.WebGLRenderer();
//     renderer.setPixelRatio(window.devicePixelRatio);
//     renderer.setSize(window.innerWidth, window.innerHeight);
//     document.body.appendChild(renderer.domElement);

//     // renderer2 = new CSS3DRenderer();
//     // renderer2.setSize(window.innerWidth, window.innerHeight);
//     // renderer2.domElement.style.position = 'absolute';
//     // renderer2.domElement.style.top = 0;
//     // document.body.appendChild(renderer2.domElement);

//     const controls = new OrbitControls(camera, renderer.domElement);
//     controls.minZoom = 0.5;
//     controls.maxZoom = 2;

//     function createPlane(width, height, cssColor, pos, rot) {

//         const element = document.createElement('div');
//         element.style.width = width + 'px';
//         element.style.height = height + 'px';
//         element.style.opacity = 0.75;
//         element.style.background = cssColor;

//         const object = new CSS3DObject(element);
//         object.position.copy(pos);
//         object.rotation.copy(rot);
//         // scene2.add(object);

//         const geometry = new THREE.PlaneGeometry(width, height);
//         const mesh = new THREE.Mesh(geometry, material);
//         mesh.position.copy(object.position);
//         mesh.rotation.copy(object.rotation);
//         scene.add(mesh);

//     }

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