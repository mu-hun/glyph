<script lang="ts">
  import { graphql } from '$glitch';
  import { TabHead, TabHeadItem } from '$lib/components/tab';
  import { css } from '$styled-system/css';
  import Footer from '../Footer.svelte';
  import Header from '../Header.svelte';

  $: query = graphql(`
    query FeedLayout_Query {
      me {
        id
      }

      ...DefaultLayout_Header_query
    }
  `);
</script>

<Header style={css.raw({ borderStyle: 'none' })} {$query} />

<div
  class={css({
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    flexGrow: '1',
    paddingBottom: { base: '96px', sm: '120px' },
    width: 'full',
    backgroundColor: 'gray.5',
  })}
>
  <TabHead
    style={css.raw({
      marginX: 'auto',
      paddingX: '20px',
      paddingBottom: '20px',
      fontSize: { base: '20px', sm: '24px' },
      width: 'full',
      maxWidth: '1280px',
    })}
  >
    <TabHeadItem id={1} style={css.raw({ fontWeight: '[800]' })} pathname="/">추천</TabHeadItem>
    {#if $query.me}
      <TabHeadItem id={2} style={css.raw({ fontWeight: '[800]' })} pathname="/feed">구독</TabHeadItem>
    {/if}
  </TabHead>

  <slot />
</div>

<Footer />
