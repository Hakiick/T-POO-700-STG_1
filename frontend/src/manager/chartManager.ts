import { ref } from 'vue';
import { BarChart } from '../components/ui/chart-bar';
import { DonutChart } from '../components/ui/chart-donut';
import { AreaChart } from '../components/ui/chart-area';
import { LineChart } from '../components/ui/line-area';

const chartTypes = ['BarChart', 'DonutChart', 'AreaChart', 'LineChart'] as const;

type ChartType = typeof chartTypes[number];

// Stocker le type de graphique
const currentChartType = ref<ChartType>('BarChart');

// Fonction pour changer le type de graphique
const setChartType = (type: ChartType) => {
  if (chartTypes.includes(type)) {
    currentChartType.value = type;
  } else {
    console.error(`Type de graphique non supporté: ${type}`);
  }
};

// Fonction pour récupérer le composant en fonction du type choisi
const getChartComponent = () => {
  switch (currentChartType.value) {
    case 'BarChart':
      return BarChart;
    case 'DonutChart':
      return DonutChart;
    case 'AreaChart':
      return AreaChart;
      case 'LineChart':
        return LineChart;
    default:
      throw new Error('Type de graphique non reconnu');
  }
};

export { chartTypes, currentChartType, setChartType, getChartComponent };
