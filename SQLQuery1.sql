create Table Employee 
(
	EmployeeID int Primary Key,
	first_name varchar(50),
	last_name varchar(50),
	full_name As (first_name + ' ' + last_name) PERSISTED,
	national_id varchar(20) Unique,
	date_of_birth date,
	country_of_birth varchar(50),
	phone varchar(15),
	email varchar(100) Unique,
	address varchar(200),
	emergency_contact_name varchar(100),
	emergency_contact_phone varchar(15),
	relationship varchar(50),
	biography text,
	profile_image varbinary(max),
	employment_progress varchar(100),
	account_status varchar(50),
	employment_status varchar(50),
	hire_date date,
	is_active bit Default 1,
	profile_completion_percentage int Check (profile_completion_percentage between 0 and 100),
	department_id int Foreign Key References Department(DepartmentID),
	position_id int Foreign Key References Position(PositionID),
	manager_id int Foreign Key References Employee(EmployeeID),
	contract_id int Foreign Key References Contract(ContractID),
	tax_form_id int Foreign Key References TaxForm(TaxFormID),
	salary_type_id int Foreign Key References SalaryType(SalaryTypeID),
	pay_grade_id int Foreign Key References PayGrade(PayGradeID),
);
create Table HRAdministrator 
(
	employee_id int Foreign Key References Employee(EmployeeID),
	approval_level varchar(50),
	record_access_scope varchar(100),
	document_validation_rights bit,
);
create Table SystemAdministrator 
(
	employee_id int Foreign Key References Employee(EmployeeID),
	system_privilege_level varchar(50),
	configurable_fields text,
	audit_visibility_scope varchar(100),
);
create Table PayrollSpecialist 
(
	employee_id int Foreign Key References Employee(EmployeeID),
	assigned_region varchar(100),
	processing_frequency varchar(50),
	last_processed_period date,
);
create Table LineManager 
(
	employee_id int Foreign Key References Employee(EmployeeID),
	team_size int,
	supervised_departments varchar(200),
	approval_limit decimal(18,2),
);
create Table Position 
(
	PositionID int Primary Key,
	position_title varchar(100),
	responsibilities text,
	status varchar(50),
);
create Table Department 
(
	DepartmentID int Primary Key,
	department_name varchar(100),
	purpose text,
	department_head_id int Foreign Key References Employee(EmployeeID),
);
create Table Skill 
(
	SkillID int Primary Key,
	skill_name varchar(100),
	description text,
);
create Table EmployeeSkill 
(
	employee_id int Foreign Key References Employee(EmployeeID),
	skill_id int Foreign Key References Skill(SkillID),
	proficiency_level varchar(50),
);
create Table Verification 
(
	VerificationID int Primary Key,
	verification_type varchar(100),
	issuer varchar(100),
	issue_date date,
	expiry_period date,
);
create Table EmployeeVerification 
(
	employee_id int Foreign Key References Employee(EmployeeID),
	verification_id int Foreign Key References Verification(VerificationID),
);
create Table Role 
(
	RoleID int Primary Key,
	role_name varchar(100),
	purpose text,
);
create Table EmployeeRole 
(
	employee_id int Foreign Key References Employee(EmployeeID),
	role_id int Foreign Key References Role(RoleID),
	assigned_date date,
);
create Table RolePermission 
(
	role_id int Foreign Key References Role(RoleID),
	permission_name varchar(100),
	allowed_action varchar(100),
);
create Table Contract 
(
	ContractID int Primary Key,
	type varchar(100),
	start_date date,
	end_date date,
	current_state varchar(50),
);
create Table FullTimeContract 
(
	contract_id int Foreign Key References Contract(ContractID),
	leave_entitlement int,
	insurance_eligibility bit,
	weekly_working_hours int,
);
create Table PartTimeContract 
(
	contract_id int Foreign Key References Contract(ContractID),
	working_hours int,
	hourly_rate decimal(18,2),
);
create Table ConsultantContract 
(
	contract_id int Foreign Key References Contract(ContractID),
	project_scope text,
	fees decimal(18,2),
	payment_schedule varchar(100),
);
create Table InternshipContract 
(
	contract_id int Foreign Key References Contract(ContractID),
	mentoring varchar(200),
	evaluation text,
	stipend_related decimal(18,2),
);
create Table Insurance 
(
	InsuranceID int Primary Key,
	type varchar(100),
	contribution_rate decimal(5,2),
	coverage text,
);
create Table Termination 
(
	TerminationID int Primary Key,
	date date,
	reason text,
	contract_id int Foreign Key References Contract(ContractID),
);
create Table Reimbursement 
(
	ReimbursementID int Primary Key,
	type varchar(100),
	claim_type varchar(100),
	approval_date date,
	current_status varchar(50),
	employee_id int Foreign Key References Employee(EmployeeID),
);
create Table Mission 
(
	MissionID int Primary Key,
	destination varchar(100),
	start_date date,
	end_date date,
	status varchar(50),
	employee_id int Foreign Key References Employee(EmployeeID),
	manager_id int Foreign Key References Employee(EmployeeID),
);
create Table Leave 
(
	LeaveID int Primary Key,
	leave_type varchar(100),
	leave_description text,
);
create Table VacationLeave 
(
	leave_id int Foreign Key References Leave(LeaveID),
	carry_over_days int,
	approving_manager varchar(100),
);
create Table SickLeave 
(
	leave_id int Foreign Key References Leave(LeaveID),
	medical_certificate_required bit,
	physician_id int, 
);
create Table ProbationLeave 
(
	leave_id int Foreign Key References Leave(LeaveID),
	eligibility_start_date date,
	probation_period int,
);
