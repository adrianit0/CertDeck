/**
 * Datos MOCK del prototipo de UI (adaptados del mockup de Google AI Studio).
 *
 * NOTA: son datos de maqueta para reproducir el diseño. La conexión a Supabase
 * (lib/queries) se hará a medida que avance el roadmap; aquí solo importa que la
 * interfaz se parezca al diseño objetivo.
 */
import type {
  Course,
  Stage,
  Topic,
  LessonWithStatus,
  LessonScreen,
  FlashcardQuestion,
} from "@/lib/types";

export const MOCK_COURSES: Course[] = [
  {
    id: "aws-saa-c03",
    title: "AWS Certified Solutions Architect - Associate",
    slug: "aws-saa-c03",
    description:
      "Diseño de arquitecturas seguras, resilientes, de alto rendimiento y optimizadas en costos en AWS.",
    icon: "Cloud",
    color: "#2563EB",
    difficulty: 4,
  },
  {
    id: "comptia-sec-plus",
    title: "CompTIA Security+ SY0-701",
    slug: "comptia-sec-plus",
    description:
      "Principios de ciberseguridad, gestión de amenazas, vulnerabilidades, criptografía y redes seguras.",
    icon: "Shield",
    color: "#0D9488",
    difficulty: 3,
  },
  {
    id: "k8s-cka",
    title: "Certified Kubernetes Administrator (CKA)",
    slug: "k8s-cka",
    description:
      "Configuración, administración, troubleshoot y diseño de clusters productivos de Kubernetes.",
    icon: "Terminal",
    color: "#7C3AED",
    difficulty: 5,
  },
];

export const MOCK_STAGES: Stage[] = [
  {
    id: "aws-stage-1",
    course_id: "aws-saa-c03",
    title: "Etapa 1: Almacenamiento, Redes y Cómputo Core",
    description: "Fundamentos clave de diseño de infraestructura resiliente utilizando servicios base.",
    position: 1,
  },
  {
    id: "aws-stage-2",
    course_id: "aws-saa-c03",
    title: "Etapa 2: Bases de Datos, Alta Disponibilidad y Serverless",
    description: "Arquitecturas modernas desacopladas y bases de datos autogestionadas.",
    position: 2,
  },
  {
    id: "sec-stage-1",
    course_id: "comptia-sec-plus",
    title: "Etapa 1: Amenazas y Ataques Comunes",
    description: "Identificación de vectores de seguridad, malware e ingeniería social.",
    position: 1,
  },
  {
    id: "k8s-stage-1",
    course_id: "k8s-cka",
    title: "Etapa 1: Configuración de Clúster y Pods",
    description: "Arquitectura interna de Kubernetes, apiserver, scheduler y pods multicarpetas.",
    position: 1,
  },
];

export const MOCK_TOPICS: Topic[] = [
  {
    id: "aws-topic-s3",
    stage_id: "aws-stage-1",
    title: "Amazon S3 y Almacenamiento de Datos",
    description: "Almacenamiento de objetos seguro y de escala ilimitada.",
    summary:
      "Aprende el funcionamiento de S3, clases de almacenamiento (Standard, Glacier) y políticas de seguridad.",
    position: 1,
  },
  {
    id: "aws-topic-ec2",
    stage_id: "aws-stage-1",
    title: "Amazon EC2 e Infraestructura de Cómputo",
    description: "Instancias virtuales, grupos de seguridad e integraciones.",
    summary:
      "Comprende el ciclo de vida de las instancias de cómputo, tipos de AMI y almacenamiento de bloque como EBS.",
    position: 2,
  },
  {
    id: "aws-topic-vpc",
    stage_id: "aws-stage-1",
    title: "Amazon VPC y Arquitectura de Redes",
    description: "Diseño de subredes, tablas de ruteo e gateways públicos/privados.",
    summary:
      "Domina el diseño de redes con subredes públicas y privadas, NAT Gateways y enrutamiento seguro.",
    position: 3,
  },
  {
    id: "aws-topic-db",
    stage_id: "aws-stage-2",
    title: "Bases de Datos Autogestionadas",
    description: "Servicios relacionales y no relacionales escalables.",
    summary: "Aprende sobre RDS, Aurora, DynamoDB y sus mecanismos de replicación multiregión.",
    position: 1,
  },
  {
    id: "sec-topic-phishing",
    stage_id: "sec-stage-1",
    title: "Ingeniería Social y Malware",
    description: "Tácticas de ataque psicológico y código malicioso.",
    summary:
      "Estudia vectores de suplantación de identidad (Phishing, Smishing) y tipos de troyanos modernos.",
    position: 1,
  },
  {
    id: "k8s-topic-core",
    stage_id: "k8s-stage-1",
    title: "Pods, ReplicaSets y Controladores",
    description: "Definición declarativa de cargas de trabajo.",
    summary:
      "Aprende YAML de pods, configuraciones de límites de recursos e ingress controllers de Kubernetes.",
    position: 1,
  },
];

export const MOCK_LESSONS: LessonWithStatus[] = [
  {
    id: "lesson-s3-1",
    topic_id: "aws-topic-s3",
    title: "Conceptos Clave de Amazon S3",
    description: "La base teórica: Buckets, objetos y jerarquía lógica.",
    lesson_type: "normal",
    position: 1,
    status: "completed",
  },
  {
    id: "lesson-s3-2",
    topic_id: "aws-topic-s3",
    title: "Clases de Almacenamiento y Ciclos de Vida",
    description: "Optimización de costos: S3 Glacier, Deep Archive e Intelligent-Tiering.",
    lesson_type: "review",
    position: 2,
    status: "available",
  },
  {
    id: "lesson-s3-3",
    topic_id: "aws-topic-s3",
    title: "Seguridad y Políticas en S3",
    description: "IAM Policies, Bucket Policies y bloqueo de acceso público.",
    lesson_type: "error_correction",
    position: 3,
    status: "locked",
  },
  {
    id: "lesson-ec2-1",
    topic_id: "aws-topic-ec2",
    title: "Uso Estratégico de Amazon EC2",
    description: "Tipos de instancias (Spot, On-Demand, Reservadas) y casos de uso.",
    lesson_type: "normal",
    position: 1,
    status: "locked",
  },
  {
    id: "lesson-ec2-2",
    topic_id: "aws-topic-ec2",
    title: "Amazon EBS y Almacenamiento persistente",
    description: "Diferencias clave entre EBS gp3, io2 e Instance Store.",
    lesson_type: "expansion",
    position: 2,
    status: "locked",
  },
  {
    id: "lesson-vpc-1",
    topic_id: "aws-topic-vpc",
    title: "Fundamentos de Virtual Private Cloud (VPC)",
    description: "Enrutamiento básico e Internet Gateways de alto rendimiento.",
    lesson_type: "normal",
    position: 1,
    status: "locked",
  },
  {
    id: "lesson-vpc-2",
    topic_id: "aws-topic-vpc",
    title: "Examen Final de Redes y Cómputo",
    description: "Simulador de preguntas avanzadas integradas.",
    lesson_type: "final",
    position: 2,
    status: "locked",
  },
  {
    id: "lesson-sec-1",
    topic_id: "sec-topic-phishing",
    title: "Tipos de Ingeniería Social",
    description: "Phishing, spear phishing, whaling y sus contramedidas.",
    lesson_type: "normal",
    position: 1,
    status: "available",
  },
  {
    id: "lesson-k8s-1",
    topic_id: "k8s-topic-core",
    title: "Ciclo de Vida de los Pods",
    description: "Estados Pending, Running, Succeeded, Failed e Init Containers.",
    lesson_type: "normal",
    position: 1,
    status: "available",
  },
];

export const MOCK_LESSON_SCREENS: LessonScreen[] = [
  {
    id: "screen-s3-2-1",
    lesson_id: "lesson-s3-2",
    title: "La Regla de Oro del Almacenamiento",
    body: "En AWS, **Amazon S3** ofrece múltiples clases para optimizar costos de acuerdo a la frecuencia de acceso.\n\nLa clase **S3 Standard** está diseñada para acceso frecuente con una disponibilidad del 99.99%. Sin embargo, tiene el costo por GB más alto.\n\nPara datos que accedes poco pero necesitas en milisegundos, usas **S3 Standard-IA** o **S3 One Zone-IA** (que solo guarda copias en una sola Zona de Disponibilidad).",
    position: 1,
  },
  {
    id: "screen-s3-2-2",
    lesson_id: "lesson-s3-2",
    title: "Archivado Frío: Glacier",
    body: "Para datos históricos o copias de seguridad de largo plazo, AWS provee las clases **S3 Glacier Flexible Retrieval** (recuperación de minutos a horas) y **S3 Glacier Deep Archive** (recuperación en 12 horas, costo ínfimo).\n\nPara mover datos automáticamente entre clases, configuras **Lifecycle Policies** (Políticas de ciclo de vida) que transicionan objetos sin intervención manual tras X días.",
    position: 2,
  },
  {
    id: "screen-s3-2-3",
    lesson_id: "lesson-s3-2",
    title: "S3 Intelligent-Tiering",
    body: "¿Qué pasa si tus patrones de acceso son **impredecibles**? \n\nNo te preocupes. **S3 Intelligent-Tiering** monitorea el bucket y realiza transiciones inteligentes entre dos capas de almacenamiento (acceso frecuente e infrecuente) automáticamente, **sin** cobrar tarifas de recuperación de datos adicionales.",
    position: 3,
  },
  {
    id: "screen-s3-1-1",
    lesson_id: "lesson-s3-1",
    title: "Amazon S3 Basics",
    body: "Amazon Simple Storage Service (**S3**) es un almacenamiento de objetos líder en la industria.\n\nLos archivos se organizan en contenedores planos llamados **Buckets**, cada uno con un nombre globalmente único. No hay jerarquía de carpetas real, sino que se simulan directorios mediante **delimitadores** (como la barra /).",
    position: 1,
  },
  {
    id: "screen-sec-1-1",
    lesson_id: "lesson-sec-1",
    title: "El Elemento Humano en Ciberseguridad",
    body: "La **Ingeniería Social** es el conjunto de técnicas psicológicas orientadas a manipular a las personas para que revelen información confidencial o realicen acciones perjudiciales.\n\nEl ataque más célebre es el **Phishing**, que consiste en la suplantación de identidad mediante correos electrónicos persuasivos falsos.",
    position: 1,
  },
  {
    id: "screen-k8s-1-1",
    lesson_id: "lesson-k8s-1",
    title: "El Ciclo de Vida de la Carga de Trabajo",
    body: "En Kubernetes, un **Pod** es la unidad de cómputo más pequeña y simple.\n\nUn Pod atraviesa una fase estructurada: **Pending** (esperando almacenamiento o asignación de nodo), **Running** (ejecutando contenedores activamente), **Succeeded** (finalizó con código de salida 0) o **Failed** (error inesperado en runtime).",
    position: 1,
  },
];

export const MOCK_QUESTIONS: FlashcardQuestion[] = [
  {
    id: "q-s3-2-1",
    lesson_id: "lesson-s3-2",
    exercise_type: "anki_card",
    question:
      "¿Cuál es el tiempo de recuperación de datos estándar para la clase **S3 Glacier Deep Archive**?",
    correct_answer: "12 horas",
    incorrect_answer_1: "Inmediato (milisegundos)",
    incorrect_answer_2: "De 3 a 5 horas",
    explanation:
      "Glacier Deep Archive es la clase de almacenamiento más barata de todo AWS y está optimizada para retención a largo plazo. Su tiempo de recuperación estándar garantizado por SLA es de 12 horas.",
  },
  {
    id: "q-s3-2-2",
    lesson_id: "lesson-s3-2",
    exercise_type: "multiple_choice",
    question:
      "Estás diseñando una solución para almacenar archivos log que se consultan raramente pero que requieren recuperación en milisegundos en caso de auditoría. ¿Qué clase de S3 optimiza costos?",
    correct_answer: "S3 Standard-IA",
    incorrect_answer_1: "S3 Glacier Instant Retrieval",
    incorrect_answer_2: "S3 Standard",
    explanation:
      "S3 Standard-Infrequent Access (Standard-IA) está optimizado para datos que se acceden rara vez pero requieren recuperación ultra rápida (milisegundos) cuando es necesario.",
  },
  {
    id: "q-s3-2-3",
    lesson_id: "lesson-s3-2",
    exercise_type: "true_false",
    question:
      "La clase **S3 One Zone-IA** ofrece el mismo nivel de redundancia ante desastres físicos de centro de datos que S3 Standard.",
    correct_answer: "Falso",
    incorrect_answer_1: "Verdadero",
    incorrect_answer_2: null,
    explanation:
      "One Zone-IA guarda los datos en una única Zona de Disponibilidad. Si dicha zona sufre un desastre físico extremo, los datos podrían perderse. S3 Standard guarda réplicas en mínimo 3 zonas distintas de forma automática.",
  },
  {
    id: "q-s3-2-4",
    lesson_id: "lesson-s3-2",
    exercise_type: "text_input",
    question:
      "¿Qué nombre técnico recibe la funcionalidad de AWS que transiciona o elimina objetos de S3 automáticamente basándose en su antigüedad? (Pista: L________)",
    correct_answer: "Lifecycle",
    incorrect_answer_1: null,
    incorrect_answer_2: null,
    explanation:
      "Las políticas de Ciclo de Vida (S3 **Lifecycle** Policies) administran automáticamente los objetos para reducir costos transicionándolos a clases más baratas o borrándolos de forma permanente.",
  },
  {
    id: "q-sec-1-1",
    lesson_id: "lesson-sec-1",
    exercise_type: "multiple_choice",
    question: "¿Qué variante de phishing se enfoca de forma altamente personalizada en directivos de alto rango?",
    correct_answer: "Whaling",
    incorrect_answer_1: "Smishing",
    incorrect_answer_2: "Vishing",
    explanation:
      "Whaling es un tipo específico de spear phishing dirigido a ejecutivos de alto nivel (como CEO, CFO) para robar grandes sumas de capital o secretos industriales.",
  },
  {
    id: "q-k8s-1-1",
    lesson_id: "lesson-k8s-1",
    exercise_type: "true_false",
    question:
      "Un Pod en Kubernetes cambia inmediatamente a la fase 'Running' tan pronto como se completa la descarga de su imagen, sin importar el estado del comando de inicio.",
    correct_answer: "Falso",
    incorrect_answer_1: "Verdadero",
    incorrect_answer_2: null,
    explanation:
      "Fase 'Running' requiere que todos los contenedores hayan arrancado exitosamente y sigan activos en ejecución. Si el comando principal crashea de inmediato, entra en CrashLoopBackOff y marca fallos.",
  },
];

/** Pool adicional de preguntas para los repasos directos de la pestaña "Repasos". */
export const MOCK_REVIEWS_POOL: FlashcardQuestion[] = [
  {
    id: "rev-1",
    lesson_id: "lesson-any",
    exercise_type: "multiple_choice",
    question:
      "¿Con qué servicio de AWS puedes configurar una dirección IP estática pública y fija que no cambie al detener e iniciar tu instancia EC2?",
    correct_answer: "Elastic IP",
    incorrect_answer_1: "Route 53 Record",
    incorrect_answer_2: "API Gateway",
    explanation:
      "Una Elastic IP es una dirección IPv4 estática diseñada para computación en la nube dinámica, que puedes asociar y desasociar libremente entre tus instancias EC2.",
  },
  {
    id: "rev-2",
    lesson_id: "lesson-any",
    exercise_type: "true_false",
    question:
      "Por defecto, todo el tráfico entrante a una subred de VPC es denegado por los Security Groups asociados a menos que se agregue una regla explícita.",
    correct_answer: "Verdadero",
    incorrect_answer_1: "Falso",
    incorrect_answer_2: null,
    explanation:
      "Los Security Groups son firewalls con estado (stateful) que por defecto deniegan todo el tráfico entrante (Inbound) y permiten todo el tráfico saliente (Outbound).",
  },
  {
    id: "rev-3",
    lesson_id: "lesson-any",
    exercise_type: "text_input",
    question: "¿Qué protocolo de encriptación usa AWS KMS para asegurar la clave principal de manera predeterminada? (3 letras)",
    correct_answer: "AES",
    incorrect_answer_1: null,
    incorrect_answer_2: null,
    explanation:
      "KMS utiliza el algoritmo simétrico AES de 256 bits (Advanced Encryption Standard) para proteger el encriptado de las claves de datos de sus clientes.",
  },
  {
    id: "rev-4",
    lesson_id: "lesson-any",
    exercise_type: "anki_card",
    question: "¿Qué significa el concepto de **Multi-AZ** en bases de datos Amazon RDS?",
    correct_answer:
      "Replicación síncrona en otra Zona de Disponibilidad para alta disponibilidad y failover automático.",
    incorrect_answer_1: "Réplica de lectura asíncrona para mejorar la velocidad en consultas simultáneas.",
    incorrect_answer_2: "Copias de seguridad automáticas en cinta fría.",
    explanation:
      "Multi-AZ crea una copia exacta en tiempo real sincronizada de tu base de datos en otra Zona de Disponibilidad. Si la primaria falla, se redirige el tráfico de forma automática (failover) transparente.",
  },
];
