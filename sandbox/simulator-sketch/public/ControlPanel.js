//import gui from threejs
// import * as dat from 'dat.gui';
import {GUI} from 'dat.gui';

export default class ControlPanel {
    
    constructor(options) {
        let cam = options.camera;


        this._gui = new GUI();
        this._cameraSettings = this._gui.addFolder('Camera');
        //open the folder
        this._cameraSettings.open();
        this._cameraSettings.add(cam.position, 'x', -1000, 1000).onChange((val) => cam.updateProjectionMatrix());
        // this._cameraSettings.add(camera.position, 'y', 100, 10000).onChange((val) => camera.updateProjectionMatrix());
        this._cameraSettings.add(cam.position, 'z', -1000, 1000).onChange((val) => cam.updateProjectionMatrix());
        this._cameraSettings.add(cam, 'zoom', 0.1, 2).onChange((val) => cam.updateProjectionMatrix());

        //make a slider for myvar
        // this._cameraSettings.add(this, 'myvar', 0, 100).onChange((val) => {
        //     console.log('myvar changed to: ' + val);
        // });
        
   }
}