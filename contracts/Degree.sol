//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;

struct student_struct{
  string name;
  string nationality;
  string RG;
  uint256 birthdate;
}

struct degree_estruct{
  bytes32 ID;
  string course;
  string academic_degree;
  uint256 completion_date;
  uint256 graduation_date;
  uint256 issue_date;
  bool is_valid;
  student_struct student;
}

contract Degree{
  string IES_name = unicode"Instituto Federal de Educação, Ciência e Tecnologia de Mato Grosso";
  string IES_acronym = "IFMT";
  string[]  IES_courses;
  
  address  authority;
  address[] issuers;
  
  mapping(bytes32 => degree_estruct)  degrees;
  bytes32[] degrees_keys;
  
  constructor(){
    authority = msg.sender;
  }
  
  modifier onlyAuthority{
    require(msg.sender == authority, "only_authority");
    _;
  }
  
  modifier onlyIssuers{
      bool is_issuer = false;
      
      for (uint16 i=0; i < issuers.length; i++){
        if(msg.sender == issuers[i])
          is_issuer = true;
      }
      
      require(is_issuer, "only_issuers");
      _;
  }
  
  function addIssuer(address _issuer) public onlyAuthority{
    require (!hasIssuer(_issuer), "issuer_already_exists");
    issuers.push(_issuer);
  }

  function removeIssuer(address _issuer) public onlyAuthority{
    int indexToBeDeleted = -1;
    
    for (uint i=0; i < issuers.length; i++){
      if (issuers[i] == _issuer){
        indexToBeDeleted = int(i);
        break;
      }
    }

    if (indexToBeDeleted < 0)
      require(false, "issuer_not_found");

    issuers[uint(indexToBeDeleted)] = issuers[issuers.length-1];
    issuers.pop(); 
  }

  function getIssuers() public view returns(address[] memory){
    return issuers;
  }

  function addCourse(string memory _course) public onlyAuthority{
    require(!hasCourse(_course), "course_already_exists");
    IES_courses.push(_course);
  }
  
  function getCourses() public view returns(string[] memory){
    return IES_courses;
  }
  
  function AddDegree(
    string memory _course,
    string memory _academic_degree,
    uint256 _completion_date,
    uint256 _graduation_date,
    uint256 _issue_date,
    string memory _student_name,
    string memory _student_nationality,
    string memory _student_RG,
    string memory _student_CPF,
    uint256 _student_birthdate
  ) public onlyIssuers returns(bytes32 degreeID){
          
    bytes32 ID = keccak256(abi.encodePacked(_student_CPF, _course));

    require(hasCourse(_course), "course_not_found");
    require(!hasDegree(ID), "degree_already_exists");
    
    degrees[ID].ID = ID;
    degrees[ID].course = _course;
    degrees[ID].academic_degree = _academic_degree;
    degrees[ID].completion_date = _completion_date;
    degrees[ID].graduation_date = _graduation_date;
    degrees[ID].issue_date = _issue_date;
    degrees[ID].student.name = _student_name;
    degrees[ID].student.nationality = _student_nationality;
    degrees[ID].student.RG = _student_RG;
    degrees[ID].student.birthdate = _student_birthdate;
    degrees[ID].is_valid = true;
    
    degrees_keys.push(ID);
    return ID;     
  }
  
  function invalidateDegree(bytes32 _ID) public onlyIssuers{
    require(hasDegree(_ID), "degree_not_found");
    require(degrees[_ID].is_valid, "degree_already_invalid");
    degrees[_ID].is_valid = false;
  }
  
  function getDegreeByID(bytes32 _ID) public view returns (degree_estruct memory r_degree){
    return degrees[_ID];
  }
  
  function getDegreeByCPFAndCourse(string memory _student_CPF, string memory _course) public view returns (degree_estruct memory r_degree){
    bytes32 ID = keccak256(abi.encodePacked(_student_CPF, _course));
    return degrees[ID];
  }
  
  function hasCourse(string memory _course) public view returns(bool r_has_course){
    for (uint16 i=0; i < IES_courses.length; i++) 
      if (keccak256(abi.encodePacked(IES_courses[i])) == keccak256(abi.encodePacked(_course)))
        return true;
    
    return false;
  }
  
  function hasIssuer(address  _issuer) public view returns(bool r_has_issuer){
    for (uint i=0; i < issuers.length; i++)
      if (issuers[i] == _issuer)
        return true;
    
    return false;
  }

  function hasDegree(bytes32 _ID) public view returns(bool r_has_degree){
    for (uint i=0; i < degrees_keys.length; i++)
      if (degrees_keys[i] == _ID)
        return true;
    
    return false;
  }

  function getDegreeIDs() public onlyAuthority view returns(bytes32[] memory r_degree_IDs){
    return degrees_keys;
  }
}
