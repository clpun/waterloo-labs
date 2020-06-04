using System;
using System.Collections;
using System.Collections.Generic;
using System.Timers;
using System.ComponentModel;
using Microsoft.Ccr.Core;
using Microsoft.Dss.Core.Attributes;
using Microsoft.Dss.ServiceModel.Dssp;
using Microsoft.Dss.ServiceModel.DsspServiceBase;
using W3C.Soap;
using submgr = Microsoft.Dss.Services.SubscriptionManager;
using brick = Microsoft.Robotics.Services.Sample.Lego.Nxt.Brick.Proxy;
using lightsensor = Microsoft.Robotics.Services.Sample.Lego.Nxt.LightSensor.Proxy;
using touchsensor = Microsoft.Robotics.Services.Sample.Lego.Nxt.TouchSensor.Proxy;
using drive = Microsoft.Robotics.Services.Sample.Lego.Nxt.Drive.Proxy;
using buttons = Microsoft.Robotics.Services.Sample.Lego.Nxt.Buttons.Proxy;
using colorv2 = Microsoft.Robotics.Services.Sample.HiTechnic.ColorV2.Proxy;

namespace Lab4_201_09
{
    public enum Shade
    {   // List of all the colors on the board
        BLACK, DARKESTGREY, DARKGREY, GREY, LIGHTGREY, WHITE, MAX
    }

    public enum Color
    {
        RED, GREEN, BLUE, YELLOW, WHITE, BLACK, DARKGREEN, UNDEF
    }

    public enum State
    {   // Defines all possible states of the robot
        ONLINE, SEARCHING, REVERSE, END, FORCING
    }

    public enum Direction
    {   // Defines the possible direction states
        LEFT, RIGHT, STRAIGHT, REVERSE, CHECKINGLEFT, CHECKINGRIGHT
    }

    [Contract(Contract.Identifier)]
    [DisplayName("Lab4_201_09")]
    [Description("Lab4_201_09 service (no description provided)")]
    class Lab4_201_09Service : DsspServiceBase
    {
        #region Variable Declarations
        const int ColorToFind = 5;
        const double drivePower = 0.05, turnPower = 0.2;
        const int queueLength = 20; // Length of light intnesity queue
        int numberOfNodes = 0;
        int intensity;              // Variable to store the latest intensity reading
        delegate void SearchDelegate(int degree);
        SearchDelegate FirstSearch, SecondSearch;
        Direction dirToCheckFor = Direction.RIGHT;
        bool buttonOn = false;      // Variable to store the on/off state of the robot
        State currentState;         // Varaible to store current state (operation mode)
        Direction currentDirection; // Variable to store the current direction of the robot
        bool motorSpinning = false; // Variable to store the state of the the motors
        long rightEncoder = 0;      //
        long leftEncoder = 0;       // Motor right and left encoders (no use for this yet)
        static Timer mainTimer = new Timer();
        static Timer queueTimer = new Timer();
        Shade currentShade;         // Variable to store the current shade of black
        Color currentColor = Color.UNDEF;         // Variable to store the current color
        bool onNode = false;
        int currentBlueIntensity, currentGreenIntensity, currentRedIntensity, currentColorNumber;
        Queue prevReadings = new Queue();       // Queue to keep track of previous readings
        #endregion

        #region PreGeneratedCode
        /// <summary>
        /// Service state
        /// </summary>
        [ServiceState]
        Lab4_201_09State _state = new Lab4_201_09State();

        /// <summary>
        /// Main service port
        /// </summary>
        [ServicePort("/Lab4_201_09", AllowMultipleInstances = true)]
        Lab4_201_09Operations _mainPort = new Lab4_201_09Operations();

        [SubscriptionManagerPartner]
        submgr.SubscriptionManagerPort _submgrPort = new submgr.SubscriptionManagerPort();

        /// <summary>
        /// NxtBrick partner
        /// </summary>
        [Partner("NxtBrick", Contract = brick.Contract.Identifier, CreationPolicy = PartnerCreationPolicy.UseExisting)]
        brick.NxtBrickOperations _nxtBrickPort = new brick.NxtBrickOperations();
        brick.NxtBrickOperations _nxtBrickNotify = new brick.NxtBrickOperations();

        /// <summary>
        /// NxtLightSensor partner
        /// </summary>
        [Partner("NxtLightSensor", Contract = lightsensor.Contract.Identifier, CreationPolicy = PartnerCreationPolicy.UseExisting)]
        lightsensor.LightSensorOperations _nxtLightSensorPort = new lightsensor.LightSensorOperations();
        lightsensor.LightSensorOperations _nxtLightSensorNotify = new lightsensor.LightSensorOperations();

        /// <summary>
        /// NxtTouchSensor partner
        /// </summary>
        [Partner("NxtTouchSensor", Contract = touchsensor.Contract.Identifier, CreationPolicy = PartnerCreationPolicy.UseExisting)]
        touchsensor.TouchSensorOperations _nxtTouchSensorPort = new touchsensor.TouchSensorOperations();
        touchsensor.TouchSensorOperations _nxtTouchSensorNotify = new touchsensor.TouchSensorOperations();

        /// <summary>
        /// NxtDrive partner
        /// </summary>
        [Partner("NxtDrive", Contract = drive.Contract.Identifier, CreationPolicy = PartnerCreationPolicy.UseExisting)]
        drive.DriveOperations _nxtDrivePort = new drive.DriveOperations();
        drive.DriveOperations _nxtDriveNotify = new drive.DriveOperations();

        /// <summary>
        /// NxtButtons partner
        /// </summary>
        [Partner("NxtButtons", Contract = buttons.Contract.Identifier, CreationPolicy = PartnerCreationPolicy.UseExisting)]
        buttons.ButtonOperations _nxtButtonsPort = new buttons.ButtonOperations();
        buttons.ButtonOperations _nxtButtonsNotify = new buttons.ButtonOperations();

        /// <summary>
        /// HiTechnicColorV2Sensor partner
        /// </summary>
        [Partner("HiTechnicColorV2Sensor", Contract = colorv2.Contract.Identifier, CreationPolicy = PartnerCreationPolicy.UseExisting)]
        colorv2.ColorV2SensorOperations _hiTechnicColorV2SensorPort = new colorv2.ColorV2SensorOperations();
        colorv2.ColorV2SensorOperations _hiTechnicColorV2SensorNotify = new colorv2.ColorV2SensorOperations();

        /// <summary>
        /// Service constructor
        /// </summary>
        public Lab4_201_09Service(DsspServiceCreationPort creationPort)
            : base(creationPort)
        {
        }
        #endregion

        #region Subscriptions
        void SubscribeToTouchSensor()
        {
            // Subscribe notification port to the control port
            _nxtTouchSensorPort.Subscribe(_nxtTouchSensorNotify);

            // Sends notfications to the touchSensorHandler function
            Activate(
                Arbiter.Receive<touchsensor.TouchSensorUpdate>
                    (true, _nxtTouchSensorNotify, touchSensorHandler));
        }
        void SubscribeToLightSensor()
        {
            // Subscribe notification port to the control port
            _nxtLightSensorPort.Subscribe(_nxtLightSensorNotify);

            // Sends notfications to the lightSensorHandler function
            Activate(
                Arbiter.Receive<lightsensor.Replace>
                    (true, _nxtLightSensorNotify, lightSensorHandler));
        }
        void SubscribeToButtonSensor()
        {
            // Subscribe notification port to the control port
            _nxtButtonsPort.Subscribe(_nxtButtonsNotify);

            // Sends notfications to the buttonSensorHandler function
            Activate(
                Arbiter.Receive<buttons.ButtonsUpdate>
                    (true, _nxtButtonsNotify, buttonSensorHandler));
        }
        void SubscribeToDriveSensor()
        {
            // Create a notification port to receive notifications from light sensor
            _nxtDrivePort.Subscribe(_nxtDriveNotify);

            // Sends notfications to the lightSensorHandler function
            Activate(
                Arbiter.Receive<drive.DriveEncodersUpdate>
                    (true, _nxtDriveNotify, driveSensorHandler));
        }
        void SubscribeToColorSensor()
        {
            // Create a notification port to receive notifications from color sensor
            _hiTechnicColorV2SensorPort.Subscribe(_hiTechnicColorV2SensorNotify);

            // Sends notfications to the colorSensorHandler function
            Activate(
                Arbiter.Receive<colorv2.ColorV2SensorUpdate>
                    (true, _hiTechnicColorV2SensorNotify, colorSensorHandler));
        }

        #endregion

        /// <summary>
        /// Handles Subscribe messages
        /// </summary>
        /// <param name="subscribe">the subscribe request</param>
        [ServiceHandler]
        public void SubscribeHandler(Subscribe subscribe)
        {
            SubscribeHelper(_submgrPort, subscribe.Body, subscribe.ResponsePort);
        }

        protected override void Start()
        {
            // Subscribe to robot sensors so we are able to receive data from the robot
            SubscribeToTouchSensor();
            SubscribeToLightSensor();
            SubscribeToButtonSensor();
            SubscribeToDriveSensor();
            SubscribeToColorSensor();

            // Turn on spotlight
            _nxtLightSensorPort.Spotlight(true);

            // Define initial search pattern (Default)
            // Search right first then left
            FirstSearch = SearchRight;
            SecondSearch = SearchLeft;

            // Set initial direction to straight
            currentDirection = Direction.STRAIGHT;

            // Start main program timer
            mainTimer.Elapsed += new ElapsedEventHandler(MainLoop);
            mainTimer.Interval = 50;    // Decide what to do every 50ms
            mainTimer.Start();

            queueTimer.Elapsed += new ElapsedEventHandler(queueHandler);
            queueTimer.Interval = 100;

            base.Start();
        }

        private void MainLoop(object source, ElapsedEventArgs e)
        {
            if (currentState == State.FORCING && motorSpinning == false)
                currentState = State.ONLINE;
            
            if (buttonOn && currentState != State.FORCING)   // Robot is on (and we are not forcing a turn)
            {   // See what color it is on and decide what to do with the drive motor
                if(currentColor == Color.BLACK) 
                {
                    // If state was previously seaching then stop robot before going straight
                    if (currentState != State.ONLINE)
                    {
                        stopRobot();
                        Console.WriteLine("Stoped before straight");
                    }
                    currentState = State.ONLINE;
                    if (FirstSearch == SearchRight)
                    {
                        dirToCheckFor = Direction.RIGHT;
                    }
                    onNode = false;             // Back on line, no longer on node
                    currentDirection = Direction.STRAIGHT;
                    driveStraight();
                }
                else if (currentColor == Color.WHITE) //(currentShade == Shade.WHITE)   // Robot went off course
                {   //  Initiate Main search pattern
                    currentState = State.SEARCHING;     // Change state to searching

                    if ((currentDirection == Direction.STRAIGHT || currentDirection == Direction.CHECKINGLEFT || currentDirection == Direction.CHECKINGRIGHT) && motorSpinning == true)
                        stopRobot();
                    
                    // Search right first
                    if((currentDirection == Direction.STRAIGHT || currentDirection == Direction.CHECKINGLEFT || currentDirection == Direction.CHECKINGRIGHT) && motorSpinning == false)
                    {
                        Console.WriteLine("White detected, first search {0}", FirstSearch.ToString());
                        FirstSearch(80);
                        // Reset delegate back to default
                        FirstSearch = SearchRight;
                        SecondSearch = SearchLeft;
                        //SearchRight(60);
                        motorSpinning = true;
                    }
                    // Search left next
                    else if (currentDirection == dirToCheckFor && motorSpinning == false)
                    {
                        Console.WriteLine("White detected, second search {0}", SecondSearch.ToString());
                        SecondSearch(200);
                        // Reset delegate back to default
                        SecondSearch = SearchLeft;
                        dirToCheckFor = Direction.RIGHT;
                    }
                }
                else if (currentColor == Color.RED)//(currentShade == Shade.LIGHTGREY || currentShade == Shade.DARKESTGREY)
                {   // Test if end is reached or just edge reading of the line
                    turnRightOnSpot(345);
                    currentState = State.FORCING;
                    Console.WriteLine("180 degree red");
                }
                else if (nodeReached(prevReadings) && !onNode)     //currentShade == Shade.GREY)
                {
                    onNode = true;
                    numberOfNodes++;
                    Console.WriteLine("Case {0}, Color: {1}", numberOfNodes, currentColor);
                    switch (numberOfNodes)
                    {
                        case 1:
                            stopRobot();
                            Console.WriteLine("Stoped before straight node");
                            currentState = State.ONLINE;
                            driveStraight();
                            break;
                        case 2:
                            stopRobot();
                            Console.WriteLine("Stoped before straight node");
                            currentState = State.ONLINE;
                            driveStraight();
                            break;
                        case 3:
                            stopRobot();
                            Console.WriteLine("Stoped before straight node");

                            // Switch search order - turn left first
                            FirstSearch = SearchLeft;
                            SecondSearch = SearchRight;
                            dirToCheckFor = Direction.LEFT;

                            currentState = State.ONLINE;
                            driveStraight();
                            break;
                        case 4:
                            stopRobot();
                            Console.WriteLine("Stoped before straight node");
                            currentState = State.ONLINE;
                            driveStraight();
                            break;
                        case 5:
                            turnRightOnSpot(160);
                            currentState = State.FORCING;
                            break;
                        case 6:
                            stopRobot();
                            Console.WriteLine("Stoped before straight node");

                            // Switch search order - turn left first
                            FirstSearch = SearchLeft;
                            SecondSearch = SearchRight;
                            dirToCheckFor = Direction.LEFT;

                            currentState = State.ONLINE;
                            driveStraight();
                            break;
                        case 7:
                            turnLeftOnSpot(300);
                            currentState = State.FORCING;
                            break;
                        case 8:
                            turnLeftOnSpot(90);
                            currentState = State.FORCING;
                            break;
                        case 9:
                            turnRightOnSpot(200);
                            currentState = State.FORCING;
                            break;
                        case 10:
                            turnRightOnSpot(230);
                            currentState = State.FORCING;
                            break;
                        case 11:
                            stopRobot();
                            Console.WriteLine("Stoped before straight node");
                            currentState = State.ONLINE;
                            driveStraight();
                            break;
                        case 12:
                            stopRobot();
                            Console.WriteLine("Stoped before straight node");
                            currentState = State.ONLINE;
                            driveStraight();
                            break;
                        case 13:
                            stopRobot();
                            Console.WriteLine("Stoped before straight node");
                            currentState = State.ONLINE;
                            driveStraight();
                            break;
                        case 14:
                            turnLeftOnSpot(230);
                            currentState = State.FORCING;
                            break;
                        case 15:
                            stopRobot();
                            Console.WriteLine("Stoped before straight node");

                            // Switch search order - turn left first
                            FirstSearch = SearchLeft;
                            SecondSearch = SearchRight;
                            dirToCheckFor = Direction.LEFT;

                            currentState = State.ONLINE;
                            driveStraight();
                            break;
                        default:
                            break;
                    }
                }
                else if (currentColor == Color.DARKGREEN)     // End condition, found color specified
                {
                    //stopRobot();
                    buttonOn = false;           // Stop robot from tracking line
                    Console.WriteLine("Found End!!");
                }
            }
        }

        #region Event Handlers
        private void colorSensorHandler(colorv2.ColorV2SensorUpdate notification)
        {
            currentBlueIntensity    = notification.Body.Blue;
            currentGreenIntensity   = notification.Body.Green;
            currentRedIntensity     = notification.Body.Red;
            currentColorNumber      = notification.Body.ColorNumber;

            if (currentColorNumber == 17 || (currentColorNumber == 13 && ((currentBlueIntensity > 110 && currentGreenIntensity < 200) || currentGreenIntensity < 120 && currentRedIntensity < 100)) || (currentColorNumber == 3 && currentBlueIntensity < 120))
                currentColor = Color.BLACK;
            else if (currentColorNumber == 3 && currentBlueIntensity > 170 && currentBlueIntensity < 240 && currentGreenIntensity < 240)
                currentColor = Color.BLUE;
            else if (currentColorNumber == 5)
                currentColor = Color.GREEN;
            else if (currentColorNumber == 10)
                currentColor = Color.RED;
            else if (currentBlueIntensity > 250 && currentGreenIntensity > 250)
                currentColor = Color.WHITE;
            else if (currentColorNumber == 13 && currentGreenIntensity > 200 && currentBlueIntensity < 110)
                currentColor = Color.YELLOW;
            else if (currentColorNumber == 4 && currentGreenIntensity > 105 && currentGreenIntensity < 130 && currentRedIntensity > 30 && currentRedIntensity < 60 && currentBlueIntensity > 60 && currentBlueIntensity < 75)    // Reads this on the light green node!!
                currentColor = Color.DARKGREEN;
            else
                currentColor = Color.UNDEF;
        }


        private void touchSensorHandler(touchsensor.TouchSensorUpdate notification)
        {
            if (notification.Body.TouchSensorOn)    // Touch sensor pressed down
            {
                Console.WriteLine("Blue: {0}, Green: {1}, Red: {2}, NUM: {3}, CurrColor: {4}",
                    currentBlueIntensity, currentGreenIntensity, currentRedIntensity, currentColorNumber, currentColor);
            }
        }

        private void lightSensorHandler(lightsensor.Replace notification)
        {
            // Set the intensity variable to the current intensity value of the light sensor
            intensity = notification.Body.Intensity;        // Get intensity
            currentShade = intensityToColor(intensity);     // Convert intensity to Color
        }

        private void buttonSensorHandler(buttons.ButtonsUpdate notification)
        {   // Left/Right buttons activate/deactivate the robot
            if (notification.Body.PressedRight)         // If right button is pressed the robot will track the line
            {
                buttonOn = true;
                queueTimer.Start();
            }
            else if (notification.Body.PressedLeft)     // If left button is pressed the robot will stop tracking the line
            {
                stopRobot();
                numberOfNodes = 0;
                prevReadings.Clear();
                buttonOn = false;
            }
        }

        private void driveSensorHandler(drive.DriveEncodersUpdate notification)
        {
            //notification.Body.RightPowerTarget vs notification.Body.RightPowerCurrent difference?

            // This sets the value of motorSpinning to true if the power of any of the motors is not 0 else it sets the
            // value to false
            if (notification.Body.RightPowerCurrent != 0 && notification.Body.LeftPowerCurrent != 0)
            {
                motorSpinning = true;
            }
            else
            {
                motorSpinning = false;
            }

            // Get current encoder readings (may use in future)
            rightEncoder = notification.Body.RightEncoderCurrent;
            leftEncoder = notification.Body.LeftEncoderCurrent;
        }
        #endregion

        #region Search Directions
        private void SearchRight(int degree)
        {   // Turn robot specified degrees to the right
            //stopRobot();
            //watchdogTimer.Start();       // Enable watchdog timer incase robot gets stuck
            turnRightOnSpot(degree);
            if (degree < 30)    // Check small degree right
            {
                Console.WriteLine("Checking right");
                currentDirection = Direction.CHECKINGRIGHT;
            }
            else
            {
                Console.WriteLine("Turning right");
                currentDirection = Direction.RIGHT;
            }
            motorSpinning = true;
        }

        private void SearchLeft(int degree)
        {   // Turn robot specified degrees to the left
            //stopRobot();
            //watchdogTimer.Start();   // Enable watchdog timer incase robot gets stuck
            turnLeftOnSpot(degree);
            if (degree < 30)     // Check small degree left
            {
                Console.WriteLine("Checking Left");
                currentDirection = Direction.CHECKINGLEFT;
            }
            else
            {
                Console.WriteLine("Turning left");
                currentDirection = Direction.LEFT;
            }
            motorSpinning = true;
        }
        #endregion

        #region Motor Drive Functions
        private void turnRightOnSpot(int degrees)
        {   // Turn robot right by the specified degree value
            drive.SetDriveRequest request = new drive.SetDriveRequest();
            request.LeftPower = turnPower;
            request.RightPower = -turnPower;
            request.LeftStopAtRotationDegrees = degrees;     // Test rotaion degrees
            request.RightStopAtRotationDegrees = degrees;
            _nxtDrivePort.DriveDistance(request);
        }

        private void turnLeftOnSpot(int degrees)
        {   // Turn robot left by the specified degree value
            drive.SetDriveRequest request = new drive.SetDriveRequest();
            request.LeftPower = -turnPower;
            request.RightPower = turnPower;
            request.LeftStopAtRotationDegrees = degrees;
            request.RightStopAtRotationDegrees = degrees;
            _nxtDrivePort.DriveDistance(request);
        }

        private void Reverse()
        {   // Send reverse request to robot
            drive.SetDriveRequest request = new drive.SetDriveRequest();
            request.LeftPower = -drivePower;
            request.RightPower = -drivePower;
            _nxtDrivePort.DriveDistance(request);
            currentDirection = Direction.REVERSE;
        }

        private void driveStraight()
        {   // Send request to robot to drive straight
            drive.SetDriveRequest request = new drive.SetDriveRequest();
            request.LeftPower = drivePower;
            request.RightPower = drivePower;
            _nxtDrivePort.DriveDistance(request);
            currentDirection = Direction.STRAIGHT;
            Console.WriteLine("Driving straight");
        }

        private void stopRobot()
        {   // Send stop request to robot
            drive.SetDriveRequest request = new drive.SetDriveRequest();
            request.LeftPower = 0.0;
            request.RightPower = 0.0;
            _nxtDrivePort.DriveDistance(request);
        }
        #endregion

        private void queueHandler(object o, ElapsedEventArgs e)
        {
            if (currentColor != Color.UNDEF)
            {
                prevReadings.Enqueue(currentColor);     // Add currentColor to list of prev readings
                if (prevReadings.Count > queueLength)            // Keep max of 10 prev readings, discard rest
                {
                    prevReadings.Dequeue();
                }
            }
        }

        private bool nodeReached(Queue q)
        {   // Determines if the robot is on a node
            // Checks for n consecutive occurances of lightgrey or darkestgrey
            const int n = 2;
            Queue tmpQ = q;
            Object[] tempArray = new Object[tmpQ.Count];
            tempArray = tmpQ.ToArray();
            
            int length = tempArray.Length;
            bool nodeReached = true;

            if ((currentColor == Color.BLUE || currentColor == Color.GREEN || currentColor == Color.YELLOW) && q.Count >= 2)
            {
                for (int i = 1; i <= n; i++)    // check last 2
                {
                    if (!(tempArray[length - (i + 1)].ToString() == tempArray[length - (i + 2)].ToString()))
                    {
                        nodeReached = false;
                    }
                }
            }
            else
                nodeReached = false;
            return nodeReached;
        }

        private void OutputQueue(Queue q)
        {   // For debuigging, output queue
            string temp = "";
            foreach (Color i in q)
            {
                switch (i)
                {
                    case Color.BLACK:
                        temp = "B";
                        break;
                    case Color.BLUE:
                        temp = "BL";
                        break;
                    case Color.GREEN:
                        temp = "Gr";
                        break;
                    case Color.WHITE:
                        temp = "W";
                        break;
                    case Color.RED:
                        temp = "r";
                        break;
                    case Color.YELLOW:
                        temp = "y";
                        break;
                    case Color.UNDEF:
                        temp = "UN";
                        break;
                    default:
                        break;
                }
                Console.Write("{0} | ", temp);
            }
            Console.WriteLine("---");
        }

        private Shade intensityToColor(int intensity)
        {   // Converts the intensity reading into the following colors
            // Black, Darkest Grey, Dark Grey, Grey, Light Grey, White
            if (intensity <= 41)
            {
                return (Shade.BLACK);
            }
            else if (intensity <= 45)
            {
                return (Shade.DARKESTGREY);
            }
            else if (intensity <= 50)
            {
                return (Shade.DARKGREY);
            }
            else if (intensity <= 54)
            {
                return (Shade.GREY);
            }
            else if (intensity <= 63)
            {
                return (Shade.LIGHTGREY);
            }
            else if (intensity < 100)
            {
                return (Shade.WHITE);
            }
            else
            {
                return (Shade.MAX);
            }
        }
    }
}