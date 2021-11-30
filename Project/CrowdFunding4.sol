// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

//Se crea contrato y se asignan variables de estado
contract CrowdFunding {
    string public id; //Referencia del proyecto
    string public name; //Nombre actual del proyecto
    string public description; 
    address payable public author; //Autor o representante del proyecto
    uint256 public state; //Estado tipo uint para que sea fácil de comparar
    uint256 public funds; //Para almacenar fondos
    uint256 public fundraisingGoal; //Define cuanto se espera ganar con la ronda de fundraising

    //Parametros de identificador de proyecto y el valor
    event ProjectFunded(string projectId, uint256 value);

    event ProjectStateChanged(string id, uint256 state);
    
    //Para quien desplegue el contrato pueda asignar valor inicial a las variables
    constructor(string memory _id, string memory _name, string memory _description, uint256 _fundraisingGoal) {
        id = _id;
        name = _name;
        description = _description;
        fundraisingGoal = _fundraisingGoal;
        author = payable(msg.sender); //Para que pueda enviar ether a esta dirección 
    }
    
    //Modificador que valida que la variable de estado de autor es igual a la dirección de quien llama la función
    modifier isAuthor() {
        require(author == msg.sender, "You need to be the project author");
        _;
    }

    //Modificador que valida que la variable de estado de autor es diferente a la dirección de quien llama la función
    modifier isNotAuthor() {
        require(
            author != msg.sender,
            "As author you can not fund your own project"
        );
        _;
    }

    //Para que cualquiera la pueda ver y enviar Ether sin problema
    function fundProject() public payable isNotAuthor{ //Autor no puede aportar a su propio proyecto
        require(state != 1, "The project can not receive funds"); //Si state = 0 no recibe más fondos
        require(msg.value > 0, "Fund value must be greater than 0"); //Si el valor enviado por usuario es mayor a cero
        author.transfer(msg.value); //Para transferir el valor de ether dado por el usuario al autor (wei)
        funds += msg.value; //Se agrega a los fondos el valor recibido
        emit ProjectFunded(id, msg.value); //Cantidad en wei que recibió el proyecto
    }

    //Recibe un nuevo estado, se guarda variable newState para optimizar gas usado en la llamada
    function changeProjectState(uint256 newState) public isAuthor{ //Solo autor es quien modifica
        require(state != newState, "New state must be different");//Si el estado actual es diferente del nuevo estado
        state = newState;
        emit ProjectStateChanged(id, newState); //Identificador del proyecto y su estado
    }
}
