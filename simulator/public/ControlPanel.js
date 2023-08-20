//import gui from threejs
// import * as dat from 'dat.gui';
import {GUI} from 'dat.gui';

export default class ControlPanel {
    
    constructor(camera) {
    
        this._gui = new GUI();
        this._cameraSettings = this._gui.addFolder('Camera');
        this._cameraSettings.add(camera.position, 'x', -100, 100).listen();
   }

   

}