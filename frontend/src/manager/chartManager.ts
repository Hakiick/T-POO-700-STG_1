import { ref } from 'vue';
import { BarChart } from '../components/ui/chart-bar';
import { DonutChart } from '../components/ui/chart-donut/index.ts';
import { AreaChart } from '../components/ui/chart-area/index.ts';
import { LineChart } from '../components/ui/chart-line/index.ts';

const chartTypes = ['BarChart', 'DonutChart', 'AreaChart', 'LineChart'] as const;

type ChartType = typeof chartTypes[number];

const currentChartType = ref<ChartType>('BarChart');

const getChartComponent = (type: ChartType, data: any, index: string, categories: string[], colors?: string[]) => {
  const props = { data, index, categories, colors };

  switch (type) {
    case 'BarChart':
      return { component: BarChart, props };
    case 'DonutChart':
      return { component: DonutChart, props: { ...props, category: categories[0], valueFormatter: props.valueFormatter } };
    case 'AreaChart':
      return { component: AreaChart, props };
    case 'LineChart':
      return { component: LineChart, props };
    default:
      throw new Error('Type de graphique non reconnu');
  }
};

export { chartTypes, currentChartType, getChartComponent };
